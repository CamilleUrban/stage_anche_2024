# Copyright (C) 2018-2022 Pico Technology Ltd. See LICENSE file for terms.
#
# PS5000A BLOCK MODE EXAMPLE
# This data is then plotted as mV against time in ns.

import ctypes
import numpy as np
from picosdk.ps5000a import ps5000a as ps
import matplotlib.pyplot as plt
from picosdk.functions import adc2mV, assert_pico_ok, mV2adc
import time

def pico(i):


	# Create chandle and status ready for use
	chandle = ctypes.c_int16()
	status = {}

	# Open 5000 series PicoScope
	# Resolution set to 12 Bit
	resolution =ps.PS5000A_DEVICE_RESOLUTION["PS5000A_DR_12BIT"]
	# Returns handle to chandle for use in future API functions
	status["openunit"] = ps.ps5000aOpenUnit(ctypes.byref(chandle), None, resolution)

	try:
		assert_pico_ok(status["openunit"])
	except: # PicoNotOkError:

		powerStatus = status["openunit"]

		if powerStatus == 286:
			status["changePowerSource"] = ps.ps5000aChangePowerSource(chandle, powerStatus)
		elif powerStatus == 282:
			status["changePowerSource"] = ps.ps5000aChangePowerSource(chandle, powerStatus)
		else:
			raise

		assert_pico_ok(status["changePowerSource"])

	# Set up channel A
	# handle = chandle
	channel = ps.PS5000A_CHANNEL["PS5000A_CHANNEL_A"]
	# ~ enabled = 1
	coupling_type = ps.PS5000A_COUPLING["PS5000A_DC"]
	chARange = ps.PS5000A_RANGE["PS5000A_5V"]
	# analogue offset = 0 V
	status["setChA"] = ps.ps5000aSetChannel(chandle, channel, 1, coupling_type, chARange, 0)
	assert_pico_ok(status["setChA"])

	# find maximum ADC count value
	maxADC = ctypes.c_int16()
	status["maximumValue"] = ps.ps5000aMaximumValue(chandle, ctypes.byref(maxADC))
	assert_pico_ok(status["maximumValue"])

	# Set up single trigger
	source = ps.PS5000A_CHANNEL["PS5000A_CHANNEL_A"]
	threshold = int(mV2adc(500,chARange, maxADC))
	status["trigger"] = ps.ps5000aSetSimpleTrigger(chandle, 1, source, threshold, 2, 0, 1000)
	assert_pico_ok(status["trigger"])

	# Set number of pre and post trigger samples to be collected
	preTriggerSamples = 0
	postTriggerSamples = 500
	maxSamples = preTriggerSamples + postTriggerSamples

	# Get timebase information
	timebase = 8
	timeIntervalns = ctypes.c_float()
	returnedMaxSamples = ctypes.c_int32()
	status["getTimebase2"] = ps.ps5000aGetTimebase2(chandle, timebase, maxSamples, ctypes.byref(timeIntervalns), ctypes.byref(returnedMaxSamples), 0)
	assert_pico_ok(status["getTimebase2"])

	# Run block capture
	status["runBlock"] = ps.ps5000aRunBlock(chandle, preTriggerSamples, postTriggerSamples, timebase, None, 0, None, None)
	assert_pico_ok(status["runBlock"])

	# Check for data collection to finish using ps5000aIsReady
	ready = ctypes.c_int16(0)
	check = ctypes.c_int16(0)
	while ready.value == check.value:
		status["isReady"] = ps.ps5000aIsReady(chandle, ctypes.byref(ready))

	# Create buffers ready for assigning pointers for data collection
	bufferAMax = (ctypes.c_int16 * maxSamples)()
	bufferAMin = (ctypes.c_int16 * maxSamples)() 

	# Set data buffer location for data collection from channel A
	source = ps.PS5000A_CHANNEL["PS5000A_CHANNEL_A"]
	status["setDataBuffersA"] = ps.ps5000aSetDataBuffers(chandle, source, ctypes.byref(bufferAMax), ctypes.byref(bufferAMin), maxSamples, 0, 0)
	assert_pico_ok(status["setDataBuffersA"])

	# create overflow loaction
	overflow = ctypes.c_int16()
	# create converted type maxSamples
	cmaxSamples = ctypes.c_int32(maxSamples)

	# Retried data from scope to buffers assigned above
	status["getValues"] = ps.ps5000aGetValues(chandle, 0, ctypes.byref(cmaxSamples), 0, 0, 0, ctypes.byref(overflow))
	assert_pico_ok(status["getValues"])


	# convert ADC counts data to mV
	adc2mVChAMax =  adc2mV(bufferAMax, chARange, maxADC)
	
	# Calcul de la moyenne
	moyenne = sum(adc2mVChAMax) / len(adc2mVChAMax)

	status["close"]=ps.ps5000aCloseUnit(chandle)
	assert_pico_ok(status["close"])

	# ~ # display status returns
	print(status)
	
	return moyenne
