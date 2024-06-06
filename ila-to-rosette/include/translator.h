#ifndef ILANGTOROSETTE_TRANSLATOR_H
#define ILANGTOROSETTE_TRANSLATOR_H
#include <ilang/ila/instr_lvl_abs.h>
#include "state_map.h"
#include <sstream>
#include <set>
#include <vector>
#include <memory>

class Translator {
public:
    explicit Translator(const ilang::InstrLvlAbsPtr& ila);
    Translator(const ilang::InstrLvlAbsPtr& ila,std::shared_ptr<StateMap> name_map);
    void generate(std::string export_dir);

    void create_const_mem_def(const std::shared_ptr<ilang::Expr>& expr);

    // DECODE
    std::string create_decode_for_instr(const std::shared_ptr<ilang::Instr> &instr_expr);
    std::stringstream generate_decode_for_model();

    // UPDATE
    std::string create_updates_for_instr(const std::shared_ptr<ilang::Instr> &instr_expr);
    std::stringstream generate_update_for_model();
    void dfs_kernel(std::stringstream& result, const std::shared_ptr<ilang::Expr>& expr);
private:
    // HELPER
    std::string get_arg_str(const std::shared_ptr<ilang::Expr>& arg);
    void increase_indent_level() { _indent_level += "    "; }
    void decrease_indent_level() { _indent_level = _indent_level.empty() ? "" : _indent_level.substr(0, _indent_level.size() - 4);}

    // DECODE and UPDATE
    enum ExprTypeId { kVar = 1, kConst, kOp };
    inline ilang::AstUidExprOp GetUidExprOp(const ilang::ExprPtr& expr);
    inline Translator::ExprTypeId GetUidExpr(const ilang::ExprPtr& expr);
    void generate_decode_assume(std::stringstream& result,
                                const std::shared_ptr<ilang::Expr>& decode_expr);

    void dfs_unary_op(std::stringstream& result, const std::shared_ptr<ilang::Expr>& expr);
    void dfs_extract_op(std::stringstream& result, const std::shared_ptr<ilang::Expr>& expr);
    void dfs_ite_op(std::stringstream& result, const std::shared_ptr<ilang::Expr>& expr);
    void dfs_bin_op(std::stringstream& result, const std::shared_ptr<ilang::Expr>& expr);
    void dfs_bin_op_load(std::stringstream& result, const std::shared_ptr<ilang::Expr>& expr);
    void dfs_bin_op_store(std::stringstream& result, const std::shared_ptr<ilang::Expr>& expr);
    void dfs_ext_op(std::stringstream& result, const std::shared_ptr<ilang::Expr>& expr);
    void generate_assert(std::stringstream& result,
                         const std::shared_ptr<ilang::Expr>& update_expr,
                         const std::shared_ptr<ilang::Expr>& updated_state);

    bool is_const_mem_load(const std::shared_ptr<ilang::Expr>& candidate);
    void dfs_const_mem_load(std::stringstream& result, const std::shared_ptr<ilang::Expr>& expr);

    struct store_assertion {
        std::string addr;
        std::string data;
        std::string mem_name;
    };
    // STATE
    std::vector<store_assertion> _mem_stores;
    std::map<std::string, std::string> _const_mem_vecs;
    ilang::InstrLvlAbsPtr _model;
    std::set<size_t> _searched_id_set;
    std::string _indent_level;
    std::shared_ptr<StateMap> _state_map;
};
#endif //ILANGTOROSETTE_TRANSLATOR_H
