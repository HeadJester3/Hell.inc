#ifndef DREAMLIB_NPC_CHARACTER_H
#define DREAMLIB_NPC_CHARACTER_H

#include "dreamlib_character.h"
#include <godot_cpp/classes/animated_sprite3d.hpp>
#include <godot_cpp/classes/timer.hpp>

namespace godot {

class DreamNPC : public DreamCharacter {
  GDCLASS(DreamNPC, DreamCharacter)

private:
  const Callable on_walk_timeout = Callable(this, "walk_timer_timeout");
  const Callable on_walk_pause_timeout = Callable(this, "walk_pause_timeout");
  const TypedArray<Vector3> RANDOM_DIRECTIONS = {
      Vector3(1.0, 0.0, 0.0),  Vector3(-1.0, 0.0, 0.0), Vector3(0.0, 0.0, 1.0),
      Vector3(0.0, 0.0, -1.0), Vector3(1.0, 0.0, 1.0),  Vector3(-1.0, 0.0, 1.0),
      Vector3(1.0, 0.0, -1.0), Vector3(-1.0, 0.0, -1.0)};

  StringName sprite_r = "right";
  StringName sprite_br = "back_right";
  StringName sprite_b = "back";
  StringName sprite_bl = "back_left";
  StringName sprite_l = "left";
  StringName sprite_fl = "front_left";
  StringName sprite_f = "front";
  StringName sprite_fr = "front_right";

  bool enable_3d_sprite = false;
  bool sprite_is_mirrored = false;
  bool enable_sprite_mirroring = true;
  AnimatedSprite3D *billboard_sprite = nullptr;

  bool enable_random_movements = false;
  bool camera_relative = true;
  bool fixed_directions = true;
  int fixed_directions_number = 8;
  double random_movements_speed = 1.0;
  Timer *random_walk_timer = nullptr;
  Timer *random_walk_pause_timer = nullptr;

protected:
  static void _bind_methods();

public:
  DreamNPC();
  ~DreamNPC();

  void _notification(int p_what);

  bool get_enable_3d_sprite() const;
  AnimatedSprite3D *get_billboard_sprite() const;
  bool get_enable_sprite_mirroring() const;
  StringName get_sprite_r() const;
  StringName get_sprite_br() const;
  StringName get_sprite_b() const;
  StringName get_sprite_bl() const;
  StringName get_sprite_l() const;
  StringName get_sprite_fl() const;
  StringName get_sprite_f() const;
  StringName get_sprite_fr() const;
  void set_enable_3d_sprite(bool p_value);
  void set_billboard_sprite(AnimatedSprite3D *p_value);
  void set_enable_sprite_mirroring(bool p_value);
  void set_sprite_r(StringName p_value);
  void set_sprite_br(StringName p_value);
  void set_sprite_b(StringName p_value);
  void set_sprite_bl(StringName p_value);
  void set_sprite_l(StringName p_value);
  void set_sprite_fl(StringName p_value);
  void set_sprite_f(StringName p_value);
  void set_sprite_fr(StringName p_value);

  StringName get_facing_angle_name();
  StringName update_sprite() const;
  bool is_sprite_face_mirrored() const;

  bool get_enable_random_movements() const;
  bool get_camera_relative() const;
  bool get_fixed_directions() const;
  int get_fixed_directions_number() const;
  double get_random_movements_speed() const;
  void set_enable_random_movements(bool p_value);
  void set_camera_relative(bool p_value);
  void set_fixed_directions(bool p_value);
  void set_fixed_directions_number(int p_value = 4);
  void set_random_movements_speed(double p_value);
  Vector3 get_random_direction() const;
  Vector3 get_random_direction_limited(int limit = 4) const;
  void move_random_direction();
  void start_random_walk();
  void walk_timer_timeout();
  void walk_pause_timeout();

  void compute_and_move_npc();
};

} // namespace godot

#endif
