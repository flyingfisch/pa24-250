##
#  action-sim.nas   Updates various simulated features including:
#                   egt, fuel pressure, oil pressure, prop visibility, 
#                   stall warning, gear scissors angles, etc. every frame
##
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

#   Initialize local variables
var rpm = nil;
var fuel_pres = 0.0;
var oil_pres = 0.0;
var factor = nil;
var ias = nil;
var flaps = nil;
var gforce = nil;
var stall = nil;
var bsw = nil;
var node = nil;
var OnGround = nil;
var fuel_flow = nil;
var egt = nil;
var rudder_position = nil;
var fuel_pump_volume = nil;
var aileron = nil;
var elevator = nil;

# set up filters for these actions

var fuel_pres_lowpass = aircraft.lowpass.new(0.5);
var oil_pres_lowpass = aircraft.lowpass.new(0.5);
var egt_lowpass = aircraft.lowpass.new(0.95);

# Properties

var propGear0 = props.globals.getNode("gear/gear[0]", 1);
var propLandingLights = props.globals.getNode("sim/model/material/LandingLight", 1);
var propFlightControls = props.globals.getNode("controls/flight", 1);
var propEngine = props.globals.getNode("engines/engine[0]", 1);
var propAirspeedIndicator = props.globals.getNode("instrumentation/airspeed-indicator", 1);
var propSurfacePositions = props.globals.getNode("surface-positions", 1);
var propCentury2bControls = props.globals.getNode("autopilot/CENTURYIIB/controls", 1);
var propCentury3Controls = props.globals.getNode("autopilot/CENTURYIII/controls", 1);

# Associate Nodes

var click = props.globals.getNode("controls/switches/click",0);
var prime = props.globals.getNode("sim/sound/prime",0);
var leftLandingLightFactor = propLandingLights.getNode("factor-L", 1);
var rightLandingLightFactor = propLandingLights.getNode("factor-R", 1);
var leftLandingLightFactorAGL  = propLandingLights.getNode("factorAGL-L", 1);
var rightLandingLightFactorAGL = propLandingLights.getNode("factorAGL-R", 1);
var fuelFlowGph = propEngine.getNode("fuel-flow-gph", 1);
var fuelPressure = propEngine.getNode("fuel-pressure-psi", 1);
var oilPressure = propEngine.getNode("oil-pressure-psi", 1);
var engineRPM = propEngine.getNode("rpm", 1);
var fixEGT = propEngine.getNode("egt-degf-fix", 1);
var flapPosition = propSurfacePositions.getNode("flap-pos-norm", 1);
var rudderPosition = propSurfacePositions.getNode("rudder-pos-norm", 1);
var indicatedAirSpeedKnots = propAirspeedIndicator.getNode("indicated-speed-kt", 1);
var noseGearPosition = propGear0.getNode("position-norm", 1);
var noseGearTurnPosition = propGear0.getNode("turn-pos-norm", 1);
var presssureAltOffsetDeg = propAirspeedIndicator.getNode("pressure-alt-offset-deg", 1);
var pilotGs = props.globals.getNode("accelerations/pilot-g", 1);
var aileronAP  = propFlightControls.getNode("AP_aileron", 1);
var elevatorAP = propFlightControls.getNode("AP_elevator", 1);
var aileronIN = propFlightControls.getNode("aileron_in", 1);
var elevatorIN = propFlightControls.getNode("elevator_in", 1);
var aileronJS = propFlightControls.getNode("aileron", 1);
var elevatorJS = propFlightControls.getNode("elevator", 1);
var pitchC3 = propCentury3Controls.getNode("pitch", 1);
var rollC3  = propCentury3Controls.getNode("roll", 1);
var rollC2b = propCentury2bControls.getNode("roll", 1);
var batterySwitch = props.globals.getNode("controls/electric/battery-switch", 1);
var noseGearWow = propGear0.getNode("wow", 1);
var aglFt = props.globals.getNode("position/altitude-agl-ft", 1);
var propDiskFactor = props.globals.getNode("sim/model/material/propdisc/factor", 1);
var fuelPump = props.globals.getNode("controls/engines/engine/fuel-pump", 1);
var fuelPumpVolume = props.globals.getNode("sim/sound/fuel_pump_volume", 1);

var init_actions = func {
#    pitchC3.setDoubleValue(0.0);
#    rollC3.setDoubleValue(0.0);
#    rollC2b.setDoubleValue(0.0);
    click.setBoolValue(0);
    leftLandingLightFactor.setDoubleValue(0.0);
    rightLandingLightFactor.setDoubleValue(0.0);
    leftLandingLightFactorAGL.setDoubleValue(0.0);
    rightLandingLightFactorAGL.setDoubleValue(0.0);
    fuelFlowGph.setDoubleValue(0.0);
    flapPosition.setDoubleValue(0.0);
    indicatedAirSpeedKnots.setDoubleValue(0.0);
    noseGearPosition.setDoubleValue(0.0);
    presssureAltOffsetDeg.setDoubleValue(0.0);
    pilotGs.setDoubleValue(0.0);
    aileronIN.setDoubleValue(0.0);
    elevatorIN.setDoubleValue(0.0);

    # Make sure that init_actions is called when the sim is reset
    setlistener("sim/signals/reset", init_actions); 

    # Request that the update fuction be called next frame
    settimer(update_actions, 0);
}


var update_actions = func {

    if ( click.getValue() ) { settimer(resetClick, 0.05); }
    if ( prime.getValue() ) { settimer(resetPrime, 0.2); }
    
##
#  This is a convenient cludge to model fuel pressure and oil pressure
##
    rpm = engineRPM.getValue();
    if (rpm > 600.0) {
       fuel_pres = 6.8-3000/rpm;
       oil_pres = 62-12600/rpm;
    } else {
       fuel_pres = 0.0;
       oil_pres = 0.0;
    }

    if ( fuelPump.getValue() ) {
    fuel_pres += 1.5;
    }

##
#  reduce fuel pump sound volume as rpm increases
##
   if (rpm < 1200) {
     fuel_pump_volume = 0.3/(0.002*rpm+1)
   } else {
     fuel_pump_volume = 0.0
   }

##
#  Save a factor used to make the prop disc disapear as rpm increases
##
    var ratio = rpm/2400;
    factor = 1.0 - ratio*ratio;
    if ( factor < 0.0 ) {
        factor = 0.0;
    }

##
#  Stall Warning
##
    ias = indicatedAirSpeedKnots.getValue();
    flaps = flapPosition.getValue();
    gforce = pilotGs.getValue();
#  pa24-250 Vs = 65 knots,  warn at 67
    stall = 65 - 7*flaps + 20*(gforce - 1.0);

    BSW = batterySwitch.getValue();
    OnGround = ( noseGearWow.getValue() );

    node = props.globals.getNode("sim/alarms/stall-warning",1);
                      
    if ( BSW and ( ias < stall ) and !OnGround ) {
      node.setBoolValue(1);
    } else {
      node.setBoolValue(0);
    }
   
##
#  Simulate egt from pilot's perspective using fuel flow and rpm
##
    fuel_flow = fuelFlowGph.getValue();
    egt = 325 - abs(fuel_flow - 12)*20;
    if (egt < 20) {egt = 20; }
    egt = egt*(rpm/2400)*(rpm/2400);

##
#  Simulate landing light ground illumination fall-off with increased agl distance
##
    var factorL = leftLandingLightFactor.getValue();
    var factorR = rightLandingLightFactor.getValue();
    var agl = aglFt.getValue();
    var aglFactor = 10000/(agl*agl);
    var factorAGL_L = factorL;
    var factorAGL_R = factorR;
    if (agl > 100) { 
       factorAGL_L = factorL*aglFactor;
       factorAGL_R = factorR*aglFactor;
    }

##
#  Disengage nose wheel steering from the rudder pedals if not locked down
##

    if ( noseGearPosition.getValue() < 1) {
        rudder_position = 0.0;
    } else {
        rudder_position = rudderPosition.getValue();
    }

##
#  Disengage Joystick aileron if autopilot is controlling roll
##

  if ( rollC3.getValue() ) { 
      aileron = aileronAP.getValue();
  } 
  elsif ( rollC2b.getValue() ) {
      aileron = aileronAP.getValue();
  } 
  else {
      aileron = aileronJS.getValue();
  }

##
#  Disengage Joystick elevator if autopilot is controlling pitch
##

  if ( pitchC3.getValue() ) {
      elevator = elevatorAP.getValue();
  }
  else {
      elevator = elevatorJS.getValue();
  }

  # outputs
    aileronIN.setDoubleValue(aileron);
    elevatorIN.setDoubleValue(elevator);
    fixEGT.setDoubleValue(egt_lowpass.filter(egt));
    leftLandingLightFactorAGL.setDoubleValue(factorAGL_L);
    rightLandingLightFactorAGL.setDoubleValue(factorAGL_R);
    noseGearTurnPosition.setDoubleValue(rudder_position);
    propDiskFactor.setDoubleValue(factor);
    fuelPressure.setDoubleValue(fuel_pres_lowpass.filter(fuel_pres));
    oilPressure.setDoubleValue(oil_pres_lowpass.filter(oil_pres));
    fuelPumpVolume.setDoubleValue(fuel_pump_volume);

    settimer(update_actions, 0);
}

var resetClick = func { click.setBoolValue(0); }
var resetPrime = func { prime.setBoolValue(0); }

# Setup listener call to start update loop once the fdm is initialized
# 
setlistener("/sim/signals/fdm-initialized", init_actions);

