# This file is part of FlightGear, the free flight simulator
# http://www.flightgear.org/
#
# Copyright (C) 2010 Dave Perry, skidavem (at) mindspring _dot_ com#
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

var value = 0;
var test = 0;
var toggle = 0;
var baggageLoaded = props.globals.getNode("sim/model/baggage/loaded",0);
baggageLoaded.setBoolValue(0);
var baggageWt_lb = props.globals.getNode("sim/weight[4]/weight-lb",0);
baggageWt_lb.setValue(0);
var leftVisorDown = props.globals.getNode("sim/model/visor-positions/leftVisorDown",0);
leftVisorDown.setBoolValue(0);
var rightVisorDown = props.globals.getNode("sim/model/visor-positions/rightVisorDown",0);
rightVisorDown.setBoolValue(0);
var click = props.globals.getNode("controls/switches/click",0);
click.setBoolValue(0);
var prime = props.globals.getNode("sim/sound/prime",0);
prime.setBoolValue(0);

var fuel_switch = func(rotDir) {
  node = props.globals.getNode("consumables/fuel/tank[0]/selected",0);
  node.setBoolValue(0);
  node = props.globals.getNode("consumables/fuel/tank[1]/selected",0);
  node.setBoolValue(0);
  node = props.globals.getNode("consumables/fuel/tank[2]/selected",0);
  node.setBoolValue(0);
  node = props.globals.getNode("consumables/fuel/tank[3]/selected",0);
  node.setBoolValue(0);

  val = getprop("controls[1]/fuel/switch-position");
  test = rotDir + val;
  if(test > 4){test=0};
  if(test < 0){test=4};
  setprop("controls[1]/fuel/switch-position",test);
  if(test == 1){
    node = props.globals.getNode("consumables/fuel/tank[0]/selected",0);
    node.setBoolValue(1);
    if(getprop("consumables/fuel/tank[0]/level-gal_us")>0.01){
      node = props.globals.getNode("engines/engine/out-of-fuel",1);
      node.setBoolValue(0);
    } 
  }
  if(test == 2){
    node = props.globals.getNode("consumables/fuel/tank[1]/selected",0);
    node.setBoolValue(1);
    if(getprop("consumables/fuel/tank[1]/level-gal_us")>0.01){
      node = props.globals.getNode("engines/engine/out-of-fuel",1);
      node.setBoolValue(0);
    } 
  }
  if(test == 3){
    node = props.globals.getNode("consumables/fuel/tank[2]/selected",0);
    node.setBoolValue(1);
    if(getprop("consumables/fuel/tank[2]/level-gal_us")>0.01){
      node = props.globals.getNode("engines/engine/out-of-fuel",1);
      node.setBoolValue(0);
    } 
  }
  if(test == 4){
    node = props.globals.getNode("consumables/fuel/tank[3]/selected",0);
    node.setBoolValue(1);
    if(getprop("consumables/fuel/tank[3]/level-gal_us")>0.01){
      node = props.globals.getNode("engines/engine/out-of-fuel",1);
      node.setBoolValue(0);
    } 
  }
}

setprop("controls[1]/fuel/switch-position", -1);
fuel_switch(1);

var baggageToggle = func {
  toggle=baggageLoaded.getValue();
  toggle=1-toggle;
  baggageLoaded.setBoolValue(toggle);
  if (toggle) {
     baggageWt_lb.setValue(122);
  } else {
     baggageWt_lb.setValue(0);
  }
}

var LeftVisorDown = func {
  toggle=leftVisorDown.getValue();
  toggle=1-toggle;
  leftVisorDown.setBoolValue(toggle);
}

var RightVisorDown = func {
  toggle=rightVisorDown.getValue();
  toggle=1-toggle;
  rightVisorDown.setBoolValue(toggle);
}

var master_switch = func {
  toggle=getprop("controls/electric/battery-switch");
  toggle=1-toggle;
  setprop("controls/electric/battery-switch",toggle);
  click.setBoolValue(1);
}

var f_pump_switch = func {
  toggle=getprop("controls/engines/engine/fuel-pump");
  toggle=1-toggle;
  setprop("controls/engines/engine/fuel-pump",toggle);
  click.setBoolValue(1);
}

var panel_light_switch = func(c) {
  var factor = getprop("controls/switches/panel-lights-factor");
  if ( (c > 0) and ( factor > 1 )) { factor = 1; return; } 
  if ( (c < 0) and ( factor < 0 )) { factor = 0; return; }
  factor = c*0.01 + factor;
  setprop("controls/switches/panel-lights-factor",factor);
  if (factor > 0.0001 ) { toggle = 1; }
  else { toggle = 0; }
  var lastToggle = getprop("controls/switches/nav-lights");
  if ( toggle != lastToggle ) {
     setprop("controls/switches/nav-lights",toggle);
     click.setBoolValue(1);
  }
}

var landing_light_switch_left = func {
  toggle=getprop("controls/switches/landing-light-L");
  toggle=1-toggle;
  setprop("controls/switches/landing-light-L",toggle);
  click.setBoolValue(1);
}

var landing_light_switch_right = func {
  toggle=getprop("controls/switches/landing-light-R");
  toggle=1-toggle;
  setprop("controls/switches/landing-light-R",toggle);
  click.setBoolValue(1);
}

var landing_light_switch_both = func {
#    SLAVE the Right switch to the Left switch
  toggle=getprop("controls/switches/landing-light-L");
  toggle=1-toggle;
  setprop("controls/switches/landing-light-L",toggle);
  setprop("controls/switches/landing-light-R",toggle);
  click.setBoolValue(1);
}

var turn_bank_switch = func {
  toggle = getprop("controls/switches/turn-indicator");
  toggle=1-toggle;
  setprop("controls/switches/turn-indicator",toggle);
  click.setBoolValue(1);
}

var rot_beacon_switch = func {
  toggle=getprop("controls/switches/flashing-beacon");
  toggle=1-toggle;
  setprop("controls/switches/flashing-beacon",toggle);
  click.setBoolValue(1);
}

var pitot_heat_switch = func {
  toggle=getprop("controls/anti-ice/pitot-heat");
  toggle=1-toggle;
  setprop("controls/anti-ice/pitot-heat",toggle);
  click.setBoolValue(1);
}

var strobe_light_switch = func {
  toggle=getprop("controls/switches/strobe-lights");
  toggle=1-toggle;
  setprop("controls/switches/strobe-lights",toggle);
  click.setBoolValue(1);
}

var avionics_master_switch = func {
  toggle=getprop("controls/switches/master-avionics");
  toggle=1-toggle;
  setprop("controls/switches/master-avionics",toggle);
  click.setBoolValue(1);
}

var carb_heat = func {
  toggle=getprop("controls/anti-ice/engine/carb-heat");
  toggle=1-toggle;
  setprop("controls/anti-ice/engine/carb-heat",toggle);
}

var primer = func {
  toggle=getprop("controls/engines/engine/primer-pump");
  toggle=1-toggle;
  setprop("controls/engines/engine/primer-pump",toggle);
  prime.setBoolValue(1);
}

var map_light_switch = func {
  toggle=getprop("controls/switches/map-lights");
  toggle=1-toggle;
  setprop("controls/switches/map-lights",toggle);
}

var cabin_light_switch = func {
  toggle=getprop("controls/switches/cabin-lights");
  toggle=1-toggle;
  setprop("controls/switches/cabin-lights",toggle);
}

var oat_switch = func {
  val = getprop("controls/switches/oat-switch");
  test = 1 + val;
  if(test > 2){test=0};
  setprop("controls/switches/oat-switch",test);
  settimer(oat_off, 300);
}

var oat_off = func {
  setprop("controls/switches/oat-switch",0);
}

##
#  Substitute controls.flapsDown taken from b29.nas.  Gives smooth flap motion
#  as long as the flap switch is closed.
##

controls.flapsDown = func(switchPosition) {
    setprop("controls/switches/flaps", switchPosition);
#    print("switchPosition = ", switchPosition);
    if(getprop("systems/electrical/outputs/flaps") < 8.0) { return; }
    if (switchPosition == 1) {
        if ( getprop('/controls/flight/flaps') < 1 ) {
            interpolate('/controls/flight/flaps', 1, (5*(1-getprop('/controls/flight/flaps'))));
        # } else {
            # check for motor burnout
        }
    } elsif (switchPosition == -1) {
        if ( getprop('/controls/flight/flaps') > 0 ) {
            interpolate('/controls/flight/flaps', 0, (5*getprop('/controls/flight/flaps')));
        # } else {
            # check for motor burnout
        }
    } else {
        interpolate('/controls/flight/flaps');
    }
}

controls.gearDown = func(switchPosition) {
    if(getprop("systems/electrical/outputs/landing-gear") < 8.0) {return; }
    if (switchPosition < 0) {
      setprop("controls/gear/gear-down", 0);
    } elsif (switchPosition > 0) {
      setprop("controls/gear/gear-down", 1);
    }
}

var sbc1 = aircraft.light.new( "sim/model/lights/sbc1", [0.5, 0.3] );
sbc1.interval = 0.1;
sbc1.switch( 1 );

var sbc2 = aircraft.light.new( "sim/model/lights/sbc2", [0.2, 0.3], "sim/model/lights/sbc1/state" );
sbc2.interval = 0;
sbc2.switch( 1 );

setlistener( "sim/model/lights/sbc2/state", func(n) {
  var bsbc1 = sbc1.stateN.getValue();
  var bsbc2 = n.getBoolValue();
  var b = 0;
  if( bsbc1 and bsbc2 and getprop( "controls/lighting/beacon") ) {
    b = 1;
  } else {
    b = 0;
  }
  setprop( "sim/model/lights/beacon/enabled", b );

  if( bsbc1 and !bsbc2 and getprop( "controls/lighting/strobe" ) ) {
    b = 1;
  } else {
    b = 0;
  }
  setprop( "sim/model/lights/strobe/enabled", b );
});

var beacon = aircraft.light.new( "sim/model/lights/beacon", [0.05, 0.05] );
beacon.interval = 0;

var strobe = aircraft.light.new( "sim/model/lights/strobe", [0.05, 0.05] );
strobe.interval = 0;
