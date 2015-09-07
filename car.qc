/*
	car.qc

	6DOF player rotation

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to:

		Free Software Foundation, Inc.
		59 Temple Place - Suite 330
		Boston, MA  02111-1307, USA

*/
float(float v) anglemod =
{
  if (v > 0)
    {
      if (v > 180)
	v = v - 360;
    }
  else
    {
      if (v < -180)
	v = v + 360;
    }
  return v;
};
vector(vector v) vectormod =
{
  v_x = anglemod(v_x);
  v_y = anglemod(v_y);
  v_z = anglemod(v_z);
  return v;
};
float(float a1, float a2) angledif = {
  local float move;
  move = anglemod(a1) - anglemod(a2);
  move = anglemod(move);
  if (a1 > a2)
    {
      if (move > 180)
	move = move - 360;
    }
  else
    {
      if (move < -180)
	move = move + 360;
    }
  move = anglemod(move);
  return move;
};
vector(vector v1, vector v2) vectordif = 
{
  local vector v;
  v_x = angledif(v1_x, v2_x);
  v_y = angledif(v1_y, v2_y);
  v_z = angledif(v1_z, v2_z);
  return v;
};
vector(vector parent, vector pole, vector orig, float t) vecrotate = {
  t *= DEG2RAD;
  local vector result;
  local float x, y, z, a, b, c, u, v, w;
  x = parent_x;
  y = parent_y;
  z = parent_z;
  u = pole_x;
  v = pole_y;
  w = pole_z;
  a = orig_x;
  b = orig_y;
  c = orig_z;
  result_x = (a*(v*v + w*w) - u*(b*v + c*w - u*x - v*y - w*z))*(1-cos(t)) + x*cos(t) + (0-c*v + b*w - w*y + v*z)*sin(t);
  result_y = (b*(u*u + w*w) - v*(a*u + c*w - u*x - v*y - w*z))*(1-cos(t)) + y*cos(t) + (c*u - a*w + w*x - u*z)*sin(t);
  result_z = (c*(u*u + v*v) - w*(a*u + b*v - u*x - v*y - w*z))*(1-cos(t)) + z*cos(t) + (0-b*u + a*v - v*x + u*y)*sin(t);
  return result;
};
vector(entity ent, vector raxis, float angle) entrotate = {//Rotates an entity about an axis, uses functions vecrotate, vectordif
  local vector angledelta = ent.angles;
  local float z, rolloffset;
  makevectors(ent.angles);
  v_forward = vecrotate(v_forward, raxis, ent.origin, angle); //rotate v_forward around axis

  z = ent.angles_z;

  ent.angles = vectoangles(v_forward);
  
  angledelta = vectordif(ent.angles, angledelta);//change in angles from roll, new z angle will be 0
  rolloffset = 0-(v_forward * '0 0 1') * angledelta_y; //removes x angle aberration
  ent.angles_z = z + (angle * (v_forward * raxis)) + rolloffset;//add z changes

  ent.angles_x *= -1;
  return ent.angles;
};
void() Car = {
  makevectors(self.car.angles);
  if(self.button3){
    self.movement_z = self.movement_y;
    self.movement_y = 0;
  }
  self.car.axis += v_right * self.movement_x + v_up * (0-self.movement_y) + v_forward * self.movement_z;
  if(vlen(self.car.axis) != 0)
    entrotate(self.car, normalize(self.car.axis), vlen(self.car.axis) * cvar("lspeed"));

  self.angles = self.car.angles;

  self.fixangle = 1;

  if(self.button2)
    self.velocity += v_forward * 5;
  self.velocity *= cvar("drag");
  self.car.axis *= cvar("ldecay");
  self.velocity_z += cvar("sv_gravity") * frametime;
};
