#ifndef ILANGTOROSETTE_STATE_MAP_H
#define ILANGTOROSETTE_STATE_MAP_H
#include <string>


class StateMap {
public:
    virtual std::string map_name_read(std::string name);
    virtual std::string map_name_write(std::string name);
    virtual ~StateMap() = default;
    StateMap() = default;
};

class RiscVStateMap: public StateMap {
public:
    std::string map_name_read(std::string name) override;
    std::string map_name_write(std::string name) override;
    ~RiscVStateMap() override = default;
    RiscVStateMap() = default;
};

class AESStateMap: public StateMap {
public:
    std::string map_name_read(std::string name) override;
    std::string map_name_write(std::string name) override;
    ~AESStateMap() override = default;
    AESStateMap() = default;
};


#endif //ILANGTOROSETTE_STATE_MAP_H
