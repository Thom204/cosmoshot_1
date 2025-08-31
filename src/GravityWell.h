#ifndef GRAVITYWELL_H
#define GRAVITYWELL_H

#include <godot_cpp/classes/static_body2d.hpp>

namespace godot {

class GravityWell : public StaticBody2D {
	GDCLASS(GravityWell, StaticBody2D)

private:
	double time_passed;

protected:
	static void _bind_methods();

public:
	GravityWell();
	~GravityWell();

	void _process(double delta) override;
};

}

#endif