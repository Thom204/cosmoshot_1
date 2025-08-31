#include "GravityWell.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void GravityWell::_bind_methods() {
}


GravityWell::GravityWell() {
}

GravityWell::~GravityWell() {
}

void GravityWell::_process(double delta) {
    call_deferred("print()", "ensayo");
}