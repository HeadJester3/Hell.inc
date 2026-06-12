
#define PRESENT_CLASS DreamCharacter

#include "dreamlib_character.h"
#include "gde_util.h"
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/project_settings.hpp>
#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/viewport.hpp>
#include <godot_cpp/variant/utility_functions.hpp>


using namespace godot;

void DreamCharacter::_bind_methods() {
	//ClassDB::bind_method(D_METHOD("adjust_facing", "facing", "target", "step", "adjust_rate", "current_gn"), &DreamCharacter::adjust_facing);
	ClassDB::bind_method(D_METHOD("set_acceleration", "value"), &DreamCharacter::set_acceleration);
	ClassDB::bind_method(D_METHOD("set_deacceleration", "value"), &DreamCharacter::set_deacceleration);
	ClassDB::bind_method(D_METHOD("set_max_speed", "value"), &DreamCharacter::set_max_speed);
	ClassDB::bind_method(D_METHOD("set_turn_speed", "value"), &DreamCharacter::set_turn_speed);
	ClassDB::bind_method(D_METHOD("set_sharp_turn_threshold", "value"), &DreamCharacter::set_sharp_turn_threshold);
	ClassDB::bind_method(D_METHOD("set_horizontal_speed", "value"), &DreamCharacter::set_horizontal_speed);
	ClassDB::bind_method(D_METHOD("set_horizontal_velocity", "value"), &DreamCharacter::set_horizontal_velocity);
	ClassDB::bind_method(D_METHOD("set_horizontal_direction", "value"), &DreamCharacter::set_horizontal_direction);
	ClassDB::bind_method(D_METHOD("set_linear_velocity", "value"), &DreamCharacter::set_linear_velocity);
	ClassDB::bind_method(D_METHOD("set_gravity_value", "value"), &DreamCharacter::set_gravity_value);

	ClassDB::bind_method(D_METHOD("get_acceleration"), &DreamCharacter::get_acceleration);
	ClassDB::bind_method(D_METHOD("get_deacceleration"), &DreamCharacter::get_deacceleration);
	ClassDB::bind_method(D_METHOD("get_max_speed"), &DreamCharacter::get_max_speed);
	ClassDB::bind_method(D_METHOD("get_turn_speed"), &DreamCharacter::get_turn_speed);
	ClassDB::bind_method(D_METHOD("get_sharp_turn_threshold"), &DreamCharacter::get_sharp_turn_threshold);
	ClassDB::bind_method(D_METHOD("get_anim_blend"), &DreamCharacter::get_anim_blend);
	ClassDB::bind_method(D_METHOD("get_horizontal_speed"), &DreamCharacter::get_horizontal_speed);
	ClassDB::bind_method(D_METHOD("get_horizontal_velocity"), &DreamCharacter::get_horizontal_velocity);
	ClassDB::bind_method(D_METHOD("get_horizontal_direction"), &DreamCharacter::get_horizontal_direction);
	ClassDB::bind_method(D_METHOD("get_direction"), &DreamCharacter::get_direction);
	ClassDB::bind_method(D_METHOD("get_linear_velocity"), &DreamCharacter::get_linear_velocity);

	ClassDB::bind_method(D_METHOD("move_character", "delta"), &DreamCharacter::move_character);
	ClassDB::bind_method(D_METHOD("is_sharp_turning"), &DreamCharacter::is_sharp_turning);
	ClassDB::bind_method(D_METHOD("set_direction", "value"), &DreamCharacter::set_direction);
	ClassDB::bind_method(D_METHOD("compute_movement_vectors", "delta"), &DreamCharacter::compute_movement_vectors);

	ClassDB::bind_method(D_METHOD("set_default_footstep", "p_value"), &DreamCharacter::set_default_footstep);
	ClassDB::bind_method(D_METHOD("get_default_footstep"), &DreamCharacter::get_default_footstep); 
	ClassDB::bind_method(D_METHOD("play_footstep"), &DreamCharacter::play_footstep);
	ClassDB::bind_method(D_METHOD("set_footstep_player", "p_value"), &DreamCharacter::set_footstep_player);
	ClassDB::bind_method(D_METHOD("get_footstep_player"), &DreamCharacter::get_footstep_player);
	ClassDB::bind_method(D_METHOD("set_" "floortype_check_raycaster", "p_value"), &DreamCharacter::set_floortype_check_raycaster);
	ClassDB::bind_method(D_METHOD("get_" "floortype_check_raycaster"), &DreamCharacter::get_floortype_check_raycaster);
	ClassDB::bind_method(D_METHOD("set_" "footsteps_volume", "p_value"), &DreamCharacter::set_footsteps_volume); 
	ClassDB::bind_method(D_METHOD("get_" "footsteps_volume"), &DreamCharacter::get_footsteps_volume); 

	ClassDB::bind_method(D_METHOD("get_interaction"), &DreamCharacter::get_interaction);
	ClassDB::bind_method(D_METHOD("set_" "player_collision_ray", "p_value"), &DreamCharacter::set_player_collision_ray); 
	ClassDB::bind_method(D_METHOD("get_" "player_collision_ray"), &DreamCharacter::get_player_collision_ray); 
	
	ClassDB::bind_method(D_METHOD("set_" "armature", "p_value"), &DreamCharacter::set_armature);
	ClassDB::bind_method(D_METHOD("get_" "armature"), &DreamCharacter::get_armature);

	ClassDB::bind_method(D_METHOD("set_direction_from_key_input"), &DreamCharacter::set_direction_from_key_input);
	ClassDB::bind_method(D_METHOD("set_direction_camera_relative", "p_value"), &DreamCharacter::set_direction_camera_relative);

	
	ClassDB::bind_method(D_METHOD("get_facing_angle"), &DreamCharacter::get_facing_angle);
	
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "max_speed", PROPERTY_HINT_RANGE, "0.0, 40.0, 0.1"), "set_max_speed", "get_max_speed");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "acceleration", PROPERTY_HINT_RANGE, "0.0 , 100.0, 0.1"), "set_acceleration", "get_acceleration");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "deacceleration", PROPERTY_HINT_RANGE, "0.0 , 100.0, 0.1"), "set_deacceleration", "get_deacceleration");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "turn_speed", PROPERTY_HINT_RANGE, "0.0 , 200.0, 1.0"), "set_turn_speed", "get_turn_speed");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "sharp_turn_threshold", PROPERTY_HINT_RANGE, "0.0 , 200.0, 1.0"), "set_sharp_turn_threshold", "get_sharp_turn_threshold");
	
	ADD_GROUP("Footstep sounds", "");
	ADD_GROUP_BOOL(enable_footstep_sounds);
	ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "footstep_player", PROPERTY_HINT_NODE_TYPE, "AudioStreamPlayer3D"), "set_footstep_player", "get_footstep_player");
	ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "default_footstep", PROPERTY_HINT_RESOURCE_TYPE, "AudioStream"), "set_default_footstep", "get_default_footstep");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "footsteps_volume", PROPERTY_HINT_RANGE, "-48.0, 48.0, 0.1, suffix:dB"), "set_" "footsteps_volume", "get_" "footsteps_volume");

	ADD_GROUP("Nodes", "");
	ClassDB ::bind_method(D_METHOD("set_""c_camera", "p_value"), &DreamCharacter ::set_c_camera);
	ClassDB ::bind_method(D_METHOD("get_""c_camera"), &DreamCharacter ::get_c_camera);
	ClassDB ::add_property(get_class_static(), PropertyInfo(Variant ::OBJECT, "c_camera", PROPERTY_HINT_NODE_TYPE, "Camera3D"), "set_" "c_camera", "get_" "c_camera");

	ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "armature", PROPERTY_HINT_NODE_TYPE, "Node3D"), "set_" "armature", "get_" "armature");
	ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "floortype_check_raycaster", PROPERTY_HINT_NODE_TYPE, "RayCast3D"), "set_" "floortype_check_raycaster", "get_" "floortype_check_raycaster");
	ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "player_collision_ray", PROPERTY_HINT_NODE_TYPE, "ShapeCast3D"), "set_" "player_collision_ray", "get_" "player_collision_ray");

    ADD_GROUP("NPC", "");
	EXPORT_PROPERTY(STRING_NAME, char_name, DreamCharacter);
	EXPORT_PROPERTY(BOOL, is_npc, DreamCharacter);

	ADD_SIGNAL(MethodInfo("interacted"));

}

DreamCharacter::DreamCharacter() {}

DreamCharacter::~DreamCharacter() {}

Camera3D *DreamCharacter ::get_c_camera() const { return c_camera; }
void DreamCharacter::set_c_camera(Camera3D *p_value) { c_camera = p_value; }

DEC_GETSET(bool, enable_footstep_sounds, DreamCharacter)

StringName DreamCharacter ::get_char_name() const { return char_name; }
void DreamCharacter ::set_char_name(StringName p_value) {char_name = p_value;}
DEC_GETSET(bool, is_npc, DreamCharacter)

Vector3 DreamCharacter::get_linear_velocity() const {return linear_velocity;}
Vector3 DreamCharacter::get_direction() const {return direction;}
Vector3 DreamCharacter::get_horizontal_direction() const {return horizontal_direction;}
Vector3 DreamCharacter::get_horizontal_velocity() const {return horizontal_velocity;}
double DreamCharacter::get_horizontal_speed() const {return horizontal_speed;}

double DreamCharacter::get_sharp_turn_threshold() const {return sharp_turn_threshold;}
double DreamCharacter::get_deacceleration() const {return deacceleration;}
double DreamCharacter::get_max_speed() const {return max_speed;}
double DreamCharacter::get_turn_speed() const {return turn_speed;}
double DreamCharacter::get_acceleration() const {return acceleration;}
void DreamCharacter::set_linear_velocity(Vector3 value) {linear_velocity = value;}
void DreamCharacter::set_sharp_turn_threshold(double value) {sharp_turn_threshold = value;}
void DreamCharacter::set_deacceleration(double value) {deacceleration = value;}
void DreamCharacter::set_max_speed(double value) {max_speed = value;}
void DreamCharacter::set_turn_speed(double value) {turn_speed = value;}
void DreamCharacter::set_acceleration(double value) {acceleration = value;}

void DreamCharacter::set_horizontal_speed(double value) {horizontal_speed = value;}
void DreamCharacter::set_horizontal_direction(Vector3 value) {horizontal_direction = value;}
void DreamCharacter::set_horizontal_velocity(Vector3 value) {horizontal_velocity = value;}
void DreamCharacter::set_gravity_value(Vector3 value) {gravity = value;}

void DreamCharacter::set_footstep_player(AudioStreamPlayer3D* p_value)	{footstep_player = p_value;}
void DreamCharacter::set_default_footstep(Ref<AudioStream> p_value)	{default_footstep = p_value;}
void DreamCharacter::set_floortype_check_raycaster(Node3D *p_value)	{floortype_check_raycaster = p_value;}
void DreamCharacter::set_footsteps_volume(double p_value)	{footsteps_volume = p_value;}
Ref<AudioStream> DreamCharacter::get_default_footstep() const	{return default_footstep;}
Node3D *DreamCharacter::get_floortype_check_raycaster() const	{return floortype_check_raycaster;}
double DreamCharacter::get_footsteps_volume() const	{return footsteps_volume;}
AudioStreamPlayer3D* DreamCharacter::get_footstep_player() const	{return footstep_player;}

void DreamCharacter::set_main_camera(Camera3D *p_value) {c_camera = p_value;}
Node3D *DreamCharacter::get_armature() const	{return armature;}
void DreamCharacter::set_armature(Node3D *p_value)	{armature = p_value;}
void DreamCharacter::set_player_collision_ray(ShapeCast3D* p_value)	{player_collision_ray = p_value;}


void DreamCharacter::_notification(int p_what){
	switch (p_what)
	{
	case NOTIFICATION_READY:
		up_vec3 = this->get_up_direction();
		if (c_camera == nullptr){
		c_camera = (this->get_viewport()->get_camera_3d());
		}
		gravity = Vector3(0.0f, -Math::absf(ProjectSettings::get_singleton()->get_setting("physics/3d/default_gravity", -3.5f)), 0.0f);
		break;

	default:
		break;
	}
}


double DreamCharacter::get_anim_blend() const {
	return Math::smoothstep(0.0, max_speed, double(get_real_velocity().length()));
}


int DreamCharacter::get_facing_angle() const {
	return ::lroundf(wrap_eight(wrap_pi((armature->get_global_rotation().y - c_camera->get_global_rotation().y)) / 0.785398f));
}


void DreamCharacter::set_direction_from_key_input(){
	if (c_camera == nullptr) {return;}
	Basis cam_basis = c_camera->get_camera_transform().get_basis();
	cam_basis.orthonormalize();
	input_vec2 = Input::get_singleton()->get_vector(input_key_left, input_key_right, input_key_up, input_key_down);
	direction = (cam_basis.xform(Vector3(input_vec2.x, 0.0f, input_vec2.y)));
	direction.y = 0.0f;
	direction = direction.normalized();
}

void DreamCharacter::set_direction(Vector3 value) {
	value.y = 0.0f;
	direction = value.normalized();
}

void DreamCharacter::set_direction_camera_relative(Vector3 p_value) {
	if (c_camera == nullptr) {return;}
	Basis cam_basis = c_camera->get_camera_transform().get_basis();
	cam_basis.orthonormalize();
	direction = cam_basis.xform(p_value);
	direction.y = 0.0f;
	direction = direction.normalized();
}

static inline Vector3 adjust_facing(const Vector3 &facing, const Vector3 &target, const double step, const double adjust_rate, const Vector3 &current_gn) {
	Vector3 t = target.cross(current_gn).normalized();
	double ang = atan2(t.dot(facing), target.dot(facing));
	if (std::abs(ang) < 0.001) {
		return facing;
	}
	double s = Math::sign(ang);
	ang = ang * s;
	double a;
	double turn = ang * adjust_rate * step;
	if (ang < turn) {
		a = ang;
	}
	else {
		a = turn;
	}
	ang = (ang - a) * s;
	
	return (target * cos(ang) + t * sin(ang)) * facing.length();
}

void DreamCharacter::compute_movement_vectors(const double delta) {
	horizontal_velocity = Vector3(linear_velocity.x, 0.0f, linear_velocity.z);
	horizontal_direction = horizontal_velocity.normalized();
	horizontal_speed = horizontal_velocity.length();
	if (direction.length() > 0.1 && !is_sharp_turning()) {
		if (horizontal_speed > 0.001) {
			horizontal_direction = adjust_facing(horizontal_direction, direction, delta, 1.0 / horizontal_speed * turn_speed, up_vec3);
		}
		else {
			horizontal_direction = direction;
		}

		if (horizontal_speed < max_speed) {
			horizontal_speed += (acceleration * delta);
		}
	}
	else {
		horizontal_speed -= (deacceleration * delta);
		if (horizontal_speed < 0.0) {
			horizontal_speed = 0.0;
		}
	}
	horizontal_velocity = (horizontal_direction * horizontal_speed);
	linear_velocity = (horizontal_velocity + up_vec3 * linear_velocity.y);
	this->set_velocity(linear_velocity + gravity);
}

inline bool DreamCharacter::is_sharp_turning() const {
	if ((horizontal_speed > 0.1) && Math::rad_to_deg(Math::acos(direction.dot(horizontal_direction))) > sharp_turn_threshold) {
		return true;
	}
	else {
		return false;
	}
}

void DreamCharacter::move_character(const double p_delta) {
	if (armature != nullptr) {
		compute_movement_vectors(p_delta);
		mesh_transform = armature->get_global_transform();
		facing_mesh = -mesh_transform.get_basis().get_column(0).normalized();
		facing_mesh = (facing_mesh - up_vec3 * facing_mesh.dot(up_vec3)).normalized();
		if (horizontal_speed > 0.01) {
			facing_mesh = adjust_facing(facing_mesh, direction, p_delta, 1.0 / horizontal_speed * turn_speed, up_vec3);
		}

		armature->set_global_transform(Transform3D(Basis(-facing_mesh, up_vec3, -facing_mesh.cross(up_vec3).normalized()).scaled(this->get_scale()).orthonormalized(), mesh_transform.get_origin()));
	}
}


void DreamCharacter::play_footstep() {
	if (footstep_player != nullptr && enable_footstep_sounds){
		if (floortype_check_raycaster != nullptr) {
			floor_collider_node = floortype_check_raycaster->call("get_collider");
			if (floor_collider_node != nullptr) {
				if (floor_collider_node->has_meta(footstep_meta)) {
					footstep_player->set_stream(floor_collider_node->get_meta(footstep_meta));
				} else {
					footstep_player->set_stream(default_footstep);
				}
			} else {
				footstep_player->set_stream(default_footstep);
			}
		} else {
			footstep_player->set_stream(default_footstep);
		}
		footstep_player->set_volume_db((footstep_player->get_volume_db() + Math::lerp(footsteps_volume - 5.0, footsteps_volume + 5.0, Math::smoothstep(0.0, max_speed, double(Vector2(get_velocity().x, get_velocity().z).length())))) / 2.0);
		footstep_player->play();
	}
}

ShapeCast3D* DreamCharacter::get_player_collision_ray() {
	if (player_collision_ray != nullptr) {
		return player_collision_ray;
	}
	if (!Engine::get_singleton()->is_editor_hint()) {
		if (this->find_child("ShapeCast3D", true) == nullptr){
			return nullptr;
		}
		player_collision_ray = static_cast<ShapeCast3D *>(this->find_child("ShapeCast3D", true));
		return player_collision_ray;
	}

	return nullptr;
}

StringName DreamCharacter::get_interaction() {
	if (player_collision_ray == nullptr) {
		player_collision_ray = get_player_collision_ray();
		if (player_collision_ray == nullptr) {
			return no_interaction;
		}
	}
	if (player_collision_ray->is_colliding()){
		Object *node_collided = player_collision_ray->get_collider(0);
		if (node_collided->get_class() != "DreamCharacter"){
			node_collided = node_collided->call("get_parent");
		}
		return node_collided->call("get_name");
	}
	return no_interaction;
}


