#ifndef DREAMLIB_CHARACTER_H
#define DREAMLIB_CHARACTER_H

#define TAUf 6.283185f
#define PIf 3.141592f

#include <godot_cpp/classes/audio_stream.hpp>
#include <godot_cpp/classes/audio_stream_player3d.hpp>
#include <godot_cpp/classes/character_body3d.hpp>
#include <godot_cpp/classes/shape_cast3d.hpp>
#include <godot_cpp/classes/camera3d.hpp>

namespace godot {

	class DreamCharacter : public CharacterBody3D {
		GDCLASS(DreamCharacter, CharacterBody3D)

	private:
		const StringName footstep_meta = "footstep";
		const StringName no_interaction = "nothing";

		const StringName input_key_up = "ui_up";
		const StringName input_key_down = "ui_down";
		const StringName input_key_right = "ui_right";
		const StringName input_key_left = "ui_left";

		StringName char_name = StringName("Unnamed");
		bool is_npc = true;

		Vector2 input_vec2 = Vector2(0.0f, 0.0f);
		
		bool sharp_turn = false;
		double horizontal_speed = 0.0;
		Vector3 linear_velocity = Vector3(0.0f, 0.0f, 0.0f);
		Vector3 horizontal_velocity = Vector3(0.0, 0.0, 0.0);
		Vector3 horizontal_direction = Vector3(0.0, 0.0, 0.0);
		Vector3 facing_mesh = Vector3(0.0, 0.0, 0.0);
		Vector3 up_vec3 = Vector3(0.0, 1.0, 0.0);
		Vector3 gravity = Vector3(0.0, 0.0, 0.0);
        Transform3D mesh_transform;

		double sharp_turn_threshold = 95.0;
		double deacceleration = 35.0;
		double max_speed = 4.5;
		double turn_speed = 100.0;
		double acceleration = 30.0;

		bool enable_footstep_sounds = true;
		AudioStreamPlayer3D *footstep_player = nullptr;
		Ref<AudioStream> default_footstep;
		double footsteps_volume = 0.0;
		
		Node3D* floortype_check_raycaster = nullptr;
		Object* floor_collider_node = nullptr;
		
		ShapeCast3D *player_collision_ray = nullptr;
		Object *node_collided = nullptr;

	protected:
		static void _bind_methods();

	public:
		DreamCharacter();
		~DreamCharacter();

		Camera3D *c_camera = nullptr;
		Node3D* armature = nullptr;
		Vector3 direction = Vector3(0.0, 0.0, 0.0);

		void _notification(int p_what);

		void set_c_camera(Camera3D* p_value);
		Camera3D* get_c_camera() const;

		double get_sharp_turn_threshold() const;
		double get_deacceleration() const;
		double get_max_speed() const;
		double get_turn_speed() const;
		double get_acceleration() const;
		double get_anim_blend() const;
		double get_horizontal_speed() const;
		Vector3 get_horizontal_velocity() const;
		Vector3 get_horizontal_direction() const;
		Vector3 get_direction() const;
		Vector3 get_linear_velocity() const;
		
		void set_direction(Vector3 value);
		void set_sharp_turn_threshold(double value);
		void set_deacceleration(double value);
		void set_max_speed(double value);
		void set_turn_speed(double value);
		void set_acceleration(double value);
		void set_horizontal_direction(Vector3 value);
		void set_horizontal_speed(double value);
		void set_horizontal_velocity(Vector3 value);
		void set_linear_velocity(Vector3 value);
		void set_gravity_value(Vector3 value);

		bool get_enable_footstep_sounds() const;
		void set_enable_footstep_sounds(bool p_value);
		void play_footstep();
		AudioStreamPlayer3D* get_footstep_player() const;
		void set_footstep_player(AudioStreamPlayer3D* p_value);
		void set_default_footstep(Ref<AudioStream> p_value);
		Ref<AudioStream> get_default_footstep() const;
		Node3D* get_floortype_check_raycaster() const;
		void set_floortype_check_raycaster(Node3D* p_value);
		void set_footsteps_volume(double p_value);
		double get_footsteps_volume() const;

		Node3D* get_armature() const;
		void set_armature(Node3D* p_value);

		void compute_movement_vectors(const double delta);
		bool is_sharp_turning() const;
		void move_character(const double p_delta);

		ShapeCast3D* get_player_collision_ray();
		void set_player_collision_ray(ShapeCast3D* p_value);
		StringName get_interaction();

		void set_direction_from_key_input();
		void set_direction_camera_relative(Vector3 p_value);
		void set_main_camera(Camera3D *p_value);

		StringName get_char_name() const; 
		void set_char_name(StringName p_value);
		bool get_is_npc() const;
		void set_is_npc(bool p_value);

		int get_facing_angle() const;

		inline float wrap_pi(float value) const {return value - (TAUf * ::floorf((value - -PIf) / TAUf));}
		inline float wrap_eight(float value) const {return value - (8.00f * ::floorf((value - -4.00f) / 8.00f));}

    };

}

#endif
