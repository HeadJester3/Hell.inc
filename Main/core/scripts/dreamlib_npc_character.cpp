
#define PRESENT_CLASS DreamNPC

#include "dreamlib_npc_character.h"
#include "gde_util.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void DreamNPC::_bind_methods() {
	ClassDB::bind_method(D_METHOD("get_random_direction"), &DreamNPC::get_random_direction);
	ClassDB::bind_method(D_METHOD("get_random_direction_limited", "limit"), &DreamNPC::get_random_direction_limited);
	ClassDB::bind_method(D_METHOD("get_facing_angle_name"), &DreamNPC::get_facing_angle_name);
	ClassDB::bind_method(D_METHOD("is_sprite_face_mirrored"), &DreamNPC::is_sprite_face_mirrored);
	ClassDB::bind_method(D_METHOD("update_sprite"), &DreamNPC::update_sprite);
	BIND_GETSET(enable_3d_sprite);
	BIND_GETSET(billboard_sprite);
	BIND_GETSET(enable_random_movements);
	BIND_SIMPLE(start_random_walk)
	BIND_SIMPLE(walk_timer_timeout)
	BIND_SIMPLE(walk_pause_timeout)
	BIND_SIMPLE(compute_and_move_npc)


	ADD_GROUP("3D Sprite", "");
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "enable_3d_sprite", PROPERTY_HINT_GROUP_ENABLE), "set_enable_3d_sprite", "get_enable_3d_sprite");
	ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "billboard_sprite", PROPERTY_HINT_NODE_TYPE, "AnimatedSprite3D"), "set_billboard_sprite", "get_billboard_sprite");
	EXPORT_PROPERTY(BOOL, enable_sprite_mirroring, DreamNPC);
	EXPORT_PROPERTY(STRING_NAME, sprite_r, DreamNPC);
	EXPORT_PROPERTY(STRING_NAME, sprite_br, DreamNPC);
	EXPORT_PROPERTY(STRING_NAME, sprite_b, DreamNPC);
	EXPORT_PROPERTY(STRING_NAME, sprite_bl, DreamNPC);
	EXPORT_PROPERTY(STRING_NAME, sprite_l, DreamNPC);
	EXPORT_PROPERTY(STRING_NAME, sprite_fl, DreamNPC);
	EXPORT_PROPERTY(STRING_NAME, sprite_f, DreamNPC);
	EXPORT_PROPERTY(STRING_NAME, sprite_fr, DreamNPC);

	ADD_GROUP("Random Movements", "");
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "enable_random_movements", PROPERTY_HINT_GROUP_ENABLE), "set_enable_random_movements", "get_enable_random_movements");
	EXPORT_PROPERTY(BOOL, camera_relative, DreamNPC);
	EXPORT_PROPERTY(BOOL, fixed_directions, DreamNPC);
	EXPORT_PROPERTY(INT, fixed_directions_number, DreamNPC);
	EXPORT_PROPERTY(FLOAT, random_movements_speed, DreamNPC);

	ADD_SIGNAL(MethodInfo("random_walk"));
	ADD_SIGNAL(MethodInfo("walking_timeout"));
}

DreamNPC::DreamNPC() {}
DreamNPC::~DreamNPC() {}

void DreamNPC::_notification(int p_what){
    switch (p_what)
	{
	case NOTIFICATION_READY:
		if (enable_random_movements) {
			start_random_walk();
		}
        break;
	default:
		break;
	}
}

DEC_GETSET(bool, enable_sprite_mirroring, DreamNPC)
DEC_GETSET(bool, enable_3d_sprite, DreamNPC)
DEC_GETSET(bool, enable_random_movements, DreamNPC)
DEC_GETSET(bool, camera_relative, DreamNPC)
DEC_GETSET(bool, fixed_directions, DreamNPC)
DEC_GETSET(int, fixed_directions_number, DreamNPC)
DEC_GETSET(double, random_movements_speed , DreamNPC)

AnimatedSprite3D *DreamNPC ::get_billboard_sprite() const {return billboard_sprite;}
void DreamNPC ::set_billboard_sprite(AnimatedSprite3D *p_value) {billboard_sprite = p_value;}

StringName DreamNPC ::get_sprite_r() const { return sprite_r; }
void DreamNPC ::set_sprite_r(StringName p_value) { sprite_r = p_value; }

StringName DreamNPC ::get_sprite_br() const { return sprite_br; }
void DreamNPC ::set_sprite_br(StringName p_value) { sprite_br = p_value; }

StringName DreamNPC ::get_sprite_b() const { return sprite_b; }
void DreamNPC ::set_sprite_b(StringName p_value) { sprite_b = p_value; }

StringName DreamNPC ::get_sprite_bl() const { return sprite_bl; }
void DreamNPC ::set_sprite_bl(StringName p_value) { sprite_bl = p_value; }

StringName DreamNPC ::get_sprite_l() const { return sprite_l; }
void DreamNPC ::set_sprite_l(StringName p_value) { sprite_l = p_value; }

StringName DreamNPC ::get_sprite_fl() const { return sprite_fl; }
void DreamNPC ::set_sprite_fl(StringName p_value) { sprite_fl = p_value; }

StringName DreamNPC ::get_sprite_f() const { return sprite_f; }
void DreamNPC ::set_sprite_f(StringName p_value) { sprite_f = p_value; }

StringName DreamNPC ::get_sprite_fr() const { return sprite_fr; }
void DreamNPC ::set_sprite_fr(StringName p_value) { sprite_fr = p_value; }


StringName DreamNPC::get_facing_angle_name() {
	if (!c_camera) return sprite_f;
	switch ( \
		::lroundf(wrap_eight(wrap_pi((armature->get_global_rotation().y - c_camera->get_global_rotation().y)) / 0.785398f))//::lroundf(Math::wrapf(Math::wrapf((armature->get_global_rotation().y - c_camera->get_global_rotation().y), -PIf, PIf) / 0.785398f, -4.0f, 4.0f))
	) {
		case -4:
			sprite_is_mirrored = false;
			return sprite_r;
		case -3:
			sprite_is_mirrored = true;
			return sprite_br;
		case -2:
			sprite_is_mirrored = false;
			return sprite_b;
		case -1:
			sprite_is_mirrored = false;
			return sprite_bl;
		case 0:
			sprite_is_mirrored = true;
			return sprite_l;
		case 1:
			sprite_is_mirrored = true;
			return sprite_fl;
		case 2:
			sprite_is_mirrored = false;
			return sprite_f;
		default:
			sprite_is_mirrored = false;
			return sprite_fr;
	}
}

StringName DreamNPC::update_sprite() const {
	if (!c_camera || !billboard_sprite || !armature) return sprite_f;
	switch (::lroundf(wrap_eight(wrap_pi((armature->get_global_rotation().y - c_camera->get_global_rotation().y)) / 0.785398f))) {
		case -4:
			if (enable_sprite_mirroring) {billboard_sprite->set_flip_h(false);}
			return sprite_r;
		case -3:
			if (enable_sprite_mirroring) {billboard_sprite->set_flip_h(true);}
			return sprite_br;
		case -2:
			if (enable_sprite_mirroring) {billboard_sprite->set_flip_h(false);}
			return sprite_b;
		case -1:
			if (enable_sprite_mirroring) {billboard_sprite->set_flip_h(false);}
			return sprite_bl;
		case 0:
			if (enable_sprite_mirroring) {billboard_sprite->set_flip_h(true);}
			return sprite_l;
		case 1:
			if (enable_sprite_mirroring) {billboard_sprite->set_flip_h(true);}
			return sprite_fl;
		case 2:
			if (enable_sprite_mirroring) {billboard_sprite->set_flip_h(false);}
			return sprite_f;
		default:
			if (enable_sprite_mirroring) {billboard_sprite->set_flip_h(false);}
			return sprite_fr;
	}
}

bool DreamNPC::is_sprite_face_mirrored() const {
	if (enable_sprite_mirroring == true) {
		return sprite_is_mirrored;
	} else {
		return false;
	}
}

Vector3 DreamNPC::get_random_direction() const {
    UtilityFunctions::randomize();
    Vector3 dir = Vector3(UtilityFunctions::randi_range(-1, 1), 0.0, UtilityFunctions::randi_range(-1, 1)).normalized();
    if (UtilityFunctions::randi_range(0, 1) != 1) {
        dir = direction.lerp(dir, 0.5).normalized();
    }
    return dir;
}

inline Vector3 DreamNPC::get_random_direction_limited(int limit) const {
	return RANDOM_DIRECTIONS[UtilityFunctions::randi_range(0, CLAMP(limit - 1, 0, 7))];
}

void DreamNPC::move_random_direction() {
	if (!enable_random_movements) return;
	if (!fixed_directions || fixed_directions_number > 8) {
		if (camera_relative) {
			set_direction_camera_relative(get_random_direction());
		} else {
			set_direction(get_random_direction());
		}
	} else {
		if (camera_relative == true && c_camera != nullptr) {
			set_direction_camera_relative(get_random_direction_limited(fixed_directions_number));
		} else {
			set_direction(get_random_direction_limited(fixed_directions_number));
		}
	}
	
}

void DreamNPC::start_random_walk() {
	if (random_walk_pause_timer == nullptr) {
		random_walk_pause_timer = memnew(Timer);
		random_walk_pause_timer->set_one_shot(true);
		random_walk_pause_timer->set_autostart(false);
		this->add_child(random_walk_pause_timer);
		random_walk_pause_timer->stop();
		random_walk_pause_timer->connect("timeout", on_walk_pause_timeout);
	}
	if (random_walk_timer == nullptr) {
		random_walk_timer = memnew(Timer);
		random_walk_timer->set_one_shot(true);
		UtilityFunctions::randomize();
		this->add_child(random_walk_timer);
		random_walk_timer->connect("timeout", on_walk_timeout);
	}
	random_walk_pause_timer->set_wait_time(Math::absf(UtilityFunctions::randfn(random_movements_speed, 0.2)));
	random_walk_timer->set_wait_time(Math::absf(UtilityFunctions::randfn(random_movements_speed, 0.2)));
	
	random_walk_timer->start();
	move_random_direction();
}

void DreamNPC::walk_timer_timeout() {
	this->emit_signal("walking_timeout");
	direction = Vector3(0.0f, 0.0f, 0.0f);
	random_walk_pause_timer->start();
}

void DreamNPC::walk_pause_timeout() {
	this->emit_signal("random_walk");
}

void DreamNPC::compute_and_move_npc() {
	move_character(get_physics_process_delta_time());
	move_and_slide();
}
