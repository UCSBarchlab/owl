#include "../include/state_map.h"
#include <fmt/format.h>

std::string RiscVStateMap::map_name_read(std::string name) {
    // heuristic for register name in this ILA
    if (name.size() >= 2 && name[0] == 'x') {
        return fmt::format("(Load (pre (ports \"rf\")) (bv {} 5))", name.substr(1));
    }
    else {
        return fmt::format("(pre (ports \"{}\"))", name);
    }
}

std::string RiscVStateMap::map_name_write(std::string name) {
    // heuristic for register name in this ILA
    if (name.size() >= 2 && name[0] == 'x') {
        return fmt::format("(Load (post (ports \"rf\")) (bv {} 5))", name.substr(1));
    }
    else {
        return fmt::format("(post (ports \"{}\"))", name);
    }
}

std::string StateMap::map_name_read(std::string name) {
    return fmt::format("\"{}\"", name);
}

std::string StateMap::map_name_write(std::string name) {
    return fmt::format("\"{}\"", name);
}
