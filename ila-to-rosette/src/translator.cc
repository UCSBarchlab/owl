#include "../include/translator.h"
#include "../include/state_map.h"
#include <fmt/format.h>
#include <filesystem>
#include <iostream>


Translator::Translator(const ilang::InstrLvlAbsPtr &ila) {
    _model = ila;
    _indent_level = "";
    _state_map = std::make_unique<StateMap>();
}

Translator::Translator(const ilang::InstrLvlAbsPtr &ila, std::shared_ptr<StateMap> name_map) {
    _model = ila;
    _indent_level = "";
    _state_map = name_map;
}

void Translator::generate(std::string export_dir) {
    std::stringstream decode = generate_decode_for_model();
    std::stringstream update = generate_update_for_model();
    std::ofstream rosette_file;
    auto fname = fmt::format("{}_rspec.rkt", _model->name().str());
    rosette_file.open(std::filesystem::path(export_dir) / std::filesystem::path(fname));
    rosette_file << "(require racket/match)" << std::endl;
    rosette_file << "(define (and-match x y) (match x [(? boolean?) (and x y)] [_ (bvand x y)]))" << std::endl;
    rosette_file << "(define (or-match x y) (match x [(? boolean?) (or x y)] [_ (bvor x y)]))" << std::endl;
    rosette_file << "(define (xor-match x y) (match x [(? boolean?) (xor x y)] [_ (bvxor x y)]))" << std::endl;
    rosette_file << "(define (Load mem addr)" << std::endl
                 << "  (let* ([mem-uninterpreted-func (vector-ref mem 0)]" << std::endl
                 << "         [mem-write-alist        (vector-ref mem 1)]" << std::endl
                 << "    (cond [read-data (cdr read-data)]" << std::endl
                 << "          [else  (apply mem-uninterpreted-func (list addr))])))" << std::endl;
    rosette_file << ";; LOOKUP TABLES" << std::endl;
    for (const auto& [key, value] : _const_mem_vecs) {
        rosette_file << value;
    }
    rosette_file << ";; DECODE FUNCS" << std::endl;
    rosette_file << decode.rdbuf();
    rosette_file << ";; UPDATE FUNCS" << std::endl;
    rosette_file << update.rdbuf();

    rosette_file.close();
}

bool Translator::is_const_mem_load(const std::shared_ptr<ilang::Expr> &candidate) {
    if (GetUidExpr(candidate) != Translator::ExprTypeId::kConst) {
        return false;
    }
    auto arg_const = std::dynamic_pointer_cast<ilang::ExprConst>(candidate);
    return arg_const->is_mem();
}

// assumes the pre environment (since post env is asserted in return func)
std::string Translator::get_arg_str(const std::shared_ptr<ilang::Expr>& arg) {
    std::string arg_str;
    if (GetUidExpr(arg) == Translator::ExprTypeId::kVar) {
        arg_str = _state_map->map_name_read(arg->name().str());
    }
    else if (GetUidExpr(arg) == Translator::ExprTypeId::kConst) {
        auto arg_const = std::dynamic_pointer_cast<ilang::ExprConst>(arg);
        if (arg->is_bool()) {
            auto arg_val = arg_const->val_bool()->val();
            if (arg_val)
                arg_str = "#t";
            else
                arg_str = "#f";
        } else if (arg->is_bv()) {
            auto bv_val = arg_const->val_bv()->val();
            auto bv_width = arg->sort()->bit_width();
            arg_str = fmt::format("(bv {} {})", bv_val, bv_width);
        } else {
            arg_str = "const_mem_" + arg->name().str();
        }
    } else
        arg_str = "c_" + std::to_string(arg->name().id());
    return arg_str;
}

inline Translator::ExprTypeId Translator::GetUidExpr(const ilang::ExprPtr& expr) {
    return expr->is_var() ? Translator::ExprTypeId::kVar
                          : expr->is_op() ? Translator::ExprTypeId::kOp : Translator::ExprTypeId::kConst;
}

inline ilang::AstUidExprOp Translator::GetUidExprOp(const ilang::ExprPtr& expr) {
    return std::dynamic_pointer_cast<ilang::ExprOp>(expr)->uid();
}

std::string Translator::create_decode_for_instr(const std::shared_ptr<ilang::Instr> &instr_expr) {
    std::stringstream dfunc;
    std::string dfunc_name = fmt::format("{}-SetDecode", instr_expr->name().str());
    dfunc << "(define (" << dfunc_name << " pre ports)" << std::endl;
    increase_indent_level();
    dfunc << _indent_level << "(let* (" << std::endl;
    increase_indent_level();
    auto decode_expr = instr_expr->decode();
    increase_indent_level();
    auto Dfskernel = [this, &dfunc](const std::shared_ptr<ilang::Expr>& e) {
        dfs_kernel(dfunc, e);
    };
    decode_expr->DepthFirstVisit(Dfskernel);
    decrease_indent_level();
    dfunc << _indent_level << ")" << std::endl;
    decrease_indent_level();
    generate_decode_assume(dfunc, decode_expr);
    decrease_indent_level();
    dfunc << _indent_level << "))" << std::endl;
    return dfunc.str();
}

std::stringstream Translator::generate_decode_for_model() {
    std::stringstream dfuncs;
    for (int i = 0; i < _model->instr_num(); i++) {
        dfuncs << create_decode_for_instr(_model->instr(i)) << std::endl;
        // need to revisit some nodes that are shared between instructions
        _searched_id_set.clear();
    }
    return dfuncs;
}

void Translator::generate_decode_assume(std::stringstream& result,
                                        const std::shared_ptr<ilang::Expr>& decode_expr) {
    auto assume_str = get_arg_str(decode_expr);
    result << _indent_level << fmt::format("(assume {})", assume_str) << std::endl;
}

// keep the variable context in let_context from previously generated instructions
// to use in future instruction defs
std::string Translator::create_updates_for_instr(const std::shared_ptr<ilang::Instr> &instr_expr) {
    std::stringstream state_func;
    std::string instr_name = instr_expr->name().str();
    // first compute the expected new states
    state_func << fmt::format("(define ({}-SetUpdate pre post ports)", instr_name) << std::endl;
    increase_indent_level();
    state_func << _indent_level << "(let* (" << std::endl;
    increase_indent_level();
    for (const auto& state_name : instr_expr->updated_states()) {
        auto updated_state = instr_expr->host()->state(state_name);
        auto update_expr = instr_expr->update(state_name);
        auto DfsKernel = [&state_func, this](const std::shared_ptr<ilang::Expr>& e) {
            dfs_kernel(state_func, e);
        };
        update_expr->DepthFirstVisit(DfsKernel);
    }
    // end let definitions
    state_func << _indent_level << ")" << std::endl;
    decrease_indent_level();

    // then assert that update is made
    for (const auto& state_name : instr_expr->updated_states()) {
        auto updated_state = instr_expr->host()->state(state_name);
        auto update_expr = instr_expr->update(state_name);
        generate_assert(state_func, update_expr, updated_state);
    }

    // assert memory updates
    while (!_mem_stores.empty()) {
        store_assertion sa = _mem_stores.back();
        _mem_stores.pop_back();
        state_func << _indent_level << fmt::format("(assert (bveq (Load (post (ports \"{}\")) {}) {}))",
                                                   sa.mem_name, sa.addr, sa.data) << std::endl;
    }
    // end let*, end define
    state_func << "))" << std::endl;
    decrease_indent_level();
    return state_func.str();
}

std::stringstream Translator::generate_update_for_model() {
    std::stringstream ufuncs;
    for (int i = 0; i < _model->instr_num(); i++) {
        ufuncs << create_updates_for_instr(_model->instr(i)) << std::endl;
        // need to revisit some nodes that are shared between instructions
        _searched_id_set.clear();
    }
    return ufuncs;
}

void Translator::generate_assert(std::stringstream& result,
                                 const std::shared_ptr<ilang::Expr>& update_expr,
                                 const std::shared_ptr<ilang::Expr>& updated_state) {
    std::string assert_expr;
    std::string return_str;
    return_str = get_arg_str(update_expr);
    auto updated_name = updated_state->name().str();
    if (!updated_state->is_mem()) {
        auto state_str = _state_map->map_name_write(updated_name);
        result << _indent_level << fmt::format("(assert (bveq {} {}))", state_str, return_str);
        result << std::endl;
    }
}

void Translator::dfs_extract_op(std::stringstream& result, const std::shared_ptr<ilang::Expr>& expr) {
    std::string arg_str = get_arg_str(expr->arg(0));
    auto param0 = static_cast<unsigned>(expr->param(0));
    auto param1 = static_cast<unsigned>(expr->param(1));
    auto out_str = "c_" + std::to_string(expr->name().id());
    auto res_str = fmt::format("[{} (extract {} {} {})]", out_str, param0, param1, arg_str);
    result << _indent_level << res_str << std::endl;
}

void Translator::dfs_ite_op(std::stringstream& result, const std::shared_ptr<ilang::Expr>& expr) {
    auto cond_str = get_arg_str(expr->arg(0));
    auto true_str = get_arg_str(expr->arg(1));
    auto false_str = get_arg_str(expr->arg(2));
    auto out_str = "c_" + std::to_string(expr->name().id());

    if (expr->is_mem()) {
        std::cout << "Unsupported memory op" << std::endl;
        return;
    }
    auto res_str = fmt::format("[{} (if {} {} {})]", out_str, cond_str, true_str, false_str);
    result << _indent_level << res_str << std::endl;
}

void Translator::dfs_bin_op(std::stringstream& result, const std::shared_ptr<ilang::Expr>& expr) {
    std::string arg0_str = get_arg_str(expr->arg(0));
    std::string arg1_str = get_arg_str(expr->arg(1));
    std::string out_str = "c_" + std::to_string(expr->name().id());

    std::string op_str;
    auto uid = GetUidExprOp(expr);
    switch (uid) {
        case ilang::AstUidExprOp::kAdd:
            op_str = "bvadd";
            break;
        case ilang::AstUidExprOp::kSubtract:
            op_str = "bvsub";
            break;
        case ilang::AstUidExprOp::kAnd:
            op_str = "and-match";
            break;
        case ilang::AstUidExprOp::kOr:
            op_str = "or-match";
            break;
        case ilang::AstUidExprOp::kXor:
            op_str = "xor-match";
            break;
        case ilang::AstUidExprOp::kShiftLeft:
            op_str = "bvshl";
            break;
        case ilang::AstUidExprOp::kArithShiftRight:
            op_str = "bvashr";
            break;
        case ilang::AstUidExprOp::kLogicShiftRight:
            op_str = "bvlshr";
            break;
        case ilang::AstUidExprOp::kMultiply:
            op_str = "bvmul";
            break;
        case ilang::AstUidExprOp::kConcatenate:
            op_str = "concat";
            break;
        case ilang::AstUidExprOp::kDivide:
            op_str = "bvsdiv";
            break;
        case ilang::AstUidExprOp::kUnsignedRemainder:
            op_str = "bvurem";
            break;
        case ilang::AstUidExprOp::kEqual:
            op_str = "bveq";
            break;
        case ilang::AstUidExprOp::kLessThan:
            op_str = "signed-lt?";
            break;
        case ilang::AstUidExprOp::kGreaterThan:
            op_str = "bvsgt";
            break;
        case ilang::AstUidExprOp::kUnsignedLessThan:
            op_str = "bvult";
            break;
        case ilang::AstUidExprOp::kUnsignedGreaterThan:
            op_str = "bvugt";
            break;
        default:
            std::cout << "Unsupported Op id: " << uid << std::endl;
            op_str = "";
    }

    auto res_str = fmt::format("[{} ({} {} {})]", out_str, op_str, arg0_str, arg1_str);
    result << _indent_level << res_str << std::endl;
}

void Translator::create_const_mem_def(const std::shared_ptr<ilang::Expr> &expr) {
    auto name = get_arg_str(expr);
    std::stringstream lookup_table;
    lookup_table << fmt::format("(define {} (vector-immutable", name) << std::endl;
    int data_width = expr->sort()->data_width();
    auto mem_const = std::dynamic_pointer_cast<ilang::ExprConst>(expr);
    auto mem_val_map = mem_const->val_mem()->val_map();
    for (const auto& [key,val] : mem_val_map) {
        lookup_table << fmt::format("(bv {} {})", val, data_width) << std::endl;
    }
    lookup_table << "))" << std::endl;
    _const_mem_vecs[name] = lookup_table.str();
}

void Translator::dfs_const_mem_load(std::stringstream &result, const std::shared_ptr<ilang::Expr> &expr) {
    std::string out_str = "c_" + std::to_string(expr->name().id());
    std::string arg0_str = get_arg_str(expr->arg(0));
    std::string arg1_str = get_arg_str(expr->arg(1));
    result << _indent_level << fmt::format("[{} (vector-ref-bv {} {})]",
                                           out_str, arg0_str, arg1_str) << std::endl;
}

void Translator::dfs_bin_op_load(std::stringstream &result,
                                 const std::shared_ptr<ilang::Expr> &expr) {

    if (is_const_mem_load(expr->arg(0))) {
        dfs_const_mem_load(result, expr);
        return;
    }

    std::string out_str = "c_" + std::to_string(expr->name().id());
    std::string arg0_str = get_arg_str(expr->arg(0));
    std::string arg1_str = get_arg_str(expr->arg(1));

    result << _indent_level << fmt::format("[{} (Load {} {})]",
                                           out_str, arg0_str, arg1_str) << std::endl;
}

void Translator::dfs_ext_op(std::stringstream &result,
                             const std::shared_ptr<ilang::Expr> &expr) {
    auto racket_op = GetUidExprOp(expr) == ilang::AstUidExprOp::kSignedExtend ?
            "sign-extend" : "zero-extend";
    auto out_str = "c_" + std::to_string(expr->name().id());
    auto arg_str = get_arg_str(expr->arg(0));
    auto target_width = expr->sort()->bit_width();
    result << _indent_level << fmt::format("[{} ({} {} (bitvector {}))]",
                                           out_str, racket_op, arg_str, target_width);
    result << std::endl;
}

void Translator::dfs_bin_op_store(std::stringstream& result, const std::shared_ptr<ilang::Expr>& expr) {
    std::string out_str = "c_" + std::to_string(expr->name().id());
    // memory name
    std::string name = expr->arg(0)->name().str();
    // address
    std::string arg1_str = get_arg_str(expr->arg(1));
    // data
    std::string arg2_str = get_arg_str(expr->arg(2));

    store_assertion sa;
    sa.addr = arg1_str;
    sa.data = arg2_str;
    sa.mem_name = name;
    _mem_stores.push_back(sa);
}

void Translator::dfs_unary_op(std::stringstream& result, const std::shared_ptr<ilang::Expr>& expr) {
    std::string arg_str = get_arg_str(expr->arg(0));
    std::string out_str = "c_" + std::to_string(expr->name().id());
    std::string op_str;
    auto expr_id = GetUidExprOp(expr);
    switch(GetUidExprOp(expr)) {
        case ilang::AstUidExprOp::kNot:
            op_str = "not";
            break;
        case ilang::AstUidExprOp::kNegate:
            op_str = "bvneg";
            break;
        case ilang::AstUidExprOp::kComplement:
            op_str = "bvnot";
            break;
        default:
            std::cout << "Unsupported Op: " << expr_id << std::endl;
            return;
    }

    result << _indent_level << fmt::format("[{} ({} {})]", out_str, op_str, arg_str) << std::endl;
}

void Translator::dfs_kernel(std::stringstream& result, const std::shared_ptr<ilang::Expr>& expr) {
    auto expr_uid = GetUidExpr(expr);
    if (expr_uid == Translator::ExprTypeId::kVar) {
        return;
    } else if (expr_uid == Translator::ExprTypeId::kConst) {
        // only significant for mem ops
        if (expr->sort()->is_mem()) {
            create_const_mem_def(expr);
        }
        return;
    } else {
        auto id = expr->name().id();
        bool op_has_been_defined =
                (_searched_id_set.find(id) != _searched_id_set.end());
        if (op_has_been_defined)
            return;
        else
            _searched_id_set.insert(id);
        auto expr_op_uid = GetUidExprOp(expr);
        switch (expr_op_uid) {
            case ilang::AstUidExprOp::kEqual:
            case ilang::AstUidExprOp::kAdd:
            case ilang::AstUidExprOp::kSubtract:
            case ilang::AstUidExprOp::kAnd:
            case ilang::AstUidExprOp::kOr:
            case ilang::AstUidExprOp::kXor:
            case ilang::AstUidExprOp::kShiftLeft:
            case ilang::AstUidExprOp::kArithShiftRight:
            case ilang::AstUidExprOp::kLogicShiftRight:
            case ilang::AstUidExprOp::kMultiply:
            case ilang::AstUidExprOp::kConcatenate:
            case ilang::AstUidExprOp::kDivide:
            case ilang::AstUidExprOp::kUnsignedRemainder:
            case ilang::AstUidExprOp::kLessThan:
            case ilang::AstUidExprOp::kGreaterThan:
            case ilang::AstUidExprOp::kUnsignedLessThan:
            case ilang::AstUidExprOp::kUnsignedGreaterThan:
                dfs_bin_op(result, expr);
                return;
            case ilang::AstUidExprOp::kLoad:
                dfs_bin_op_load(result, expr);
                return;
            case ilang::AstUidExprOp::kStore:
                dfs_bin_op_store(result, expr);
                return;
            case ilang::AstUidExprOp::kExtract:
                dfs_extract_op(result, expr);
                return;
            case ilang::AstUidExprOp::kIfThenElse:
                dfs_ite_op(result, expr);
                return;
            case ilang::AstUidExprOp::kSignedExtend:
            case ilang::AstUidExprOp::kZeroExtend:
                dfs_ext_op(result, expr);
                return;
            case ilang::AstUidExprOp::kNegate:
            case ilang::AstUidExprOp::kNot:
            case ilang::AstUidExprOp::kComplement:
                dfs_unary_op(result, expr);
                return;
            default:
                std::cout << "Unsupported: " << expr_op_uid << std::endl;
        }
    }
}


