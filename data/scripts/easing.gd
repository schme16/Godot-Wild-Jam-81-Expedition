extends Node;
const NATURAL_LOG_OF_2 = 0.693147181
const HALF = 0.5
const ONE = 1.0
const TWO = 2.0
const PI_HALF = PI * HALF
const S_CURVE = 1.70158
const BOUNCE_BASE = 2.75

func spring(start: float, end: float, value: float) -> float:
	value = clamp(value, 0.0, ONE)
	value = (sin(value * PI * (0.2 + 2.5 * value * value * value)) * pow(ONE - value, 2.2) + value) * (ONE + (1.2 * (ONE - value)))
	return start + (end - start) * value

func ease_in_quad(start: float, end: float, value: float) -> float:
	return (end - start) * value * value + start

func ease_out_quad(start: float, end: float, value: float) -> float:
	return -(end - start) * value * (value - TWO) + start

func ease_in_out_quad(start: float, end: float, value: float) -> float:
	var end_minus_start = end - start
	value = value / HALF
	if value < ONE:
		return end_minus_start * HALF * value * value + start
	value -= ONE
	return -end_minus_start * HALF * (value * (value - TWO) - ONE) + start

func ease_in_cubic(start: float, end: float, value: float) -> float:
	return (end - start) * value * value * value + start

func ease_out_cubic(start: float, end: float, value: float) -> float:
	value -= ONE
	return (end - start) * (value * value * value + ONE) + start

func ease_in_out_cubic(start: float, end: float, value: float) -> float:
	var end_minus_start = end - start
	value = value / HALF
	if value < ONE:
		return end_minus_start * HALF * value * value * value + start
	value -= TWO
	return end_minus_start * HALF * (value * value * value + TWO) + start

func ease_in_quart(start: float, end: float, value: float) -> float:
	return (end - start) * value * value * value * value + start

func ease_out_quart(start: float, end: float, value: float) -> float:
	value -= ONE
	return -(end - start) * (value * value * value * value - ONE) + start

func ease_in_out_quart(start: float, end: float, value: float) -> float:
	var end_minus_start = end - start
	value = value / HALF
	if value < ONE:
		return end_minus_start * HALF * value * value * value * value + start
	value -= TWO
	return -end_minus_start * HALF * (value * value * value * value - TWO) + start

func ease_in_quint(start: float, end: float, value: float) -> float:
	return (end - start) * value * value * value * value * value + start

func ease_out_quint(start: float, end: float, value: float) -> float:
	value -= ONE
	return (end - start) * (value * value * value * value * value + ONE) + start

func ease_in_out_quint(start: float, end: float, value: float) -> float:
	var end_minus_start = end - start
	value = value / HALF
	if value < ONE:
		return end_minus_start * HALF * value * value * value * value * value + start
	value -= TWO
	return end_minus_start * HALF * (value * value * value * value * value + TWO) + start

func ease_in_sine(start: float, end: float, value: float) -> float:
	var end_minus_start = end - start
	return -end_minus_start * cos(value * PI_HALF) + end_minus_start + start

func ease_out_sine(start: float, end: float, value: float) -> float:
	return (end - start) * sin(value * PI_HALF) + start

func ease_in_out_sine(start: float, end: float, value: float) -> float:
	return -(end - start) * HALF * (cos(PI * value) - ONE) + start

func ease_in_expo(start: float, end: float, value: float) -> float:
	return (end - start) * pow(TWO, 10 * (value - ONE)) + start

func ease_out_expo(start: float, end: float, value: float) -> float:
	return (end - start) * (-pow(TWO, -10 * value) + ONE) + start

func ease_in_out_expo(start: float, end: float, value: float) -> float:
	var end_minus_start = end - start
	value = value / HALF
	if value < ONE:
		return end_minus_start * HALF * pow(TWO, 10 * (value - ONE)) + start
	value -= ONE
	return end_minus_start * HALF * (-pow(TWO, -10 * value) + TWO) + start

func ease_in_circ(start: float, end: float, value: float) -> float:
	return -(end - start) * (sqrt(ONE - value * value) - ONE) + start

func ease_out_circ(start: float, end: float, value: float) -> float:
	value -= ONE
	return (end - start) * sqrt(ONE - value * value) + start

func ease_in_out_circ(start: float, end: float, value: float) -> float:
	var end_minus_start = end - start
	value = value / HALF
	if value < ONE:
		return -end_minus_start * HALF * (sqrt(ONE - value * value) - ONE) + start
	value -= TWO
	return end_minus_start * HALF * (sqrt(ONE - value * value) + ONE) + start

func ease_in_bounce(start: float, end: float, value: float) -> float:
	var end_minus_start = end - start
	return end_minus_start - ease_out_bounce(0, end_minus_start, ONE - value) + start

func ease_out_bounce(start: float, end: float, value: float) -> float:
	var end_minus_start = end - start

	if value < (ONE / BOUNCE_BASE):
		return end_minus_start * (7.5625 * value * value) + start
	elif value < (TWO / BOUNCE_BASE):
		value -= (1.5 / BOUNCE_BASE)
		return end_minus_start * (7.5625 * value * value + 0.75) + start
	elif value < (2.5 / BOUNCE_BASE):
		value -= (2.25 / BOUNCE_BASE)
		return end_minus_start * (7.5625 * value * value + 0.9375) + start
	else:
		value -= (2.625 / BOUNCE_BASE)
		return end_minus_start * (7.5625 * value * value + 0.984375) + start

func ease_in_out_bounce(start: float, end: float, value: float) -> float:
	var end_minus_start = end - start
	if value < HALF:
		return ease_in_bounce(0, end_minus_start, value * TWO) * HALF + start
	else:
		return ease_out_bounce(0, end_minus_start, value * TWO - ONE) * HALF + end_minus_start * HALF + start

func ease_in_back(start: float, end: float, value: float) -> float:
	var end_minus_start = end - start
	return end_minus_start * value * value * ((S_CURVE + ONE) * value - S_CURVE) + start

func ease_out_back(start: float, end: float, value: float) -> float:
	var end_minus_start = end - start
	value = value - ONE
	return end_minus_start * (value * value * ((S_CURVE + ONE) * value + S_CURVE) + ONE) + start

func ease_in_out_back(start: float, end: float, value: float) -> float:
	var end_minus_start = end - start
	var s = S_CURVE
	value = value / HALF
	if value < ONE:
		s *= 1.525
		return end_minus_start * HALF * (value * value * (((s) + ONE) * value - s)) + start
	value -= TWO
	s *= 1.525
	return end_minus_start * HALF * (value * value * (((s) + ONE) * value + s) + TWO) + start

func ease_in_elastic(start: float, end: float, value: float) -> float:
	var end_minus_start = end - start

	if value == 0:
		return start

	value = value / ONE
	if value == ONE:
		return start + end_minus_start

	var p = 0.3
	var s = p / 4

	if end_minus_start != 0:
		s = p / (TWO * PI) * asin(ONE)

	value -= ONE
	return -(end_minus_start * pow(TWO, 10 * value) * sin((value - s) * (TWO * PI) / p)) + start

func ease_out_elastic(start: float, end: float, value: float) -> float:
	var end_minus_start = end - start

	if value == 0:
		return start

	value = value / ONE
	if value == ONE:
		return start + end_minus_start

	var p = 0.3
	var s = p * 0.25

	if end_minus_start != 0:
		s = p / (TWO * PI) * asin(ONE)

	return (end_minus_start * pow(TWO, -10 * value) * sin((value - s) * (TWO * PI) / p) + end_minus_start + start)

func ease_in_out_elastic(start: float, end: float, value: float) -> float:
	var end_minus_start = end - start

	if value == 0:
		return start

	value = value / (HALF)
	if value == TWO:
		return start + end_minus_start

	var p = 0.3 * 1.5
	var s = p / 4

	if end_minus_start != 0:
		s = p / (TWO * PI) * asin(ONE)

	if value < ONE:
		value -= ONE
		return -HALF * (end_minus_start * pow(TWO, 10 * value) * sin((value - s) * (TWO * PI) / p)) + start

	value -= ONE
	return end_minus_start * pow(TWO, -10 * value) * sin((value - s) * (TWO * PI) / p) * HALF + end_minus_start + start
