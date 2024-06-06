#include "../ilas/ila-include/simple_cpu.h"
#include "../ilas/ila-include/pipe_ila.h"
#include "../ilas/ila-include/riscvila.h"
#include "translator.h"
#include "../include/state_map.h"
#include <ilang/target-json/ila_to_json_serializer.h>
#include <ilang/target-json/interface.h>
#include <ilang/target-sc/ila_sim.h>
#include <ilang/verilog-out/verilog_gen.h>
#include <ilang/ilang++.h>
#include "../ilas/ila-include/aes_ila.h"
#include "../ilas/ila-include/aes_128.h"

#include <iostream>


int main() {

    auto risc = ilang::riscvILA_user(0);
    risc.addInstructions();
    auto model = risc.getModel().get();

// Uncomment here for aes model instead (make sure to comment out the lines above)
//    auto model = AES_128().model.get();

    auto map = std::make_shared<RiscVStateMap>();
    Translator t(model, map);
    t.generate("./");
    return 0;
}
