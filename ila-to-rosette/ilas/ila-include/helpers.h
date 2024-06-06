#ifndef ILANGTOROSETTE_HELPERS_H
#define ILANGTOROSETTE_HELPERS_H
/********************
 ILA helpers
********************/

#include <ilang/ila/instr_lvl_abs.h>
#include <ilang/ilang++.h>

#include <list>
typedef std::list<ilang::ExprRef> exp_list;
ilang::ExprRef lConcat(const exp_list& l);


#endif //ILANGTOROSETTE_HELPERS_H
