extends Node

const WAVEFORM_H: int = 100
const WAVEFORM_W: int = 1280

const BG_COLOR: Color = Color("2E2A43")

const TRACK_TEMPO_DEFAULT: int = 120
const TRACK_TEMPO_MAX: int = 900

const TRACK_DISTANCE: int = 5

const CURSOR_FOCUS_OFFSET: int = 0

var last_file_path: String = "//"

const CELLS_IN_QUARTER_COUNT: int = 4
const CELL_WIDTH: float = 14.0
const CELL_HEIGHT: float = 28.0
const CELL_EXPORT_SCALE: float = 5.0
const QUARTERS_COUNT: int = 4

const DEFAULT_COLOR: Color = Color(71 / 255.0, 187 / 255.0, 255 / 255.0, 1)
const TRACKS_DISTANCE: int = 5

const COLOR: String = "ffffff00"
const EXTENDED: String = "extended"
const ACCENT: String = "accent"

@warning_ignore("narrowing_conversion")
var HEIGHT: int = CELL_HEIGHT
@warning_ignore("narrowing_conversion")
var WIDTH: int = CELL_WIDTH

var MEMBERS_NAME: Array = []
var COLOR_SELECTED: Array = []


#var COLORS = [white, red, green, yellow, pink, fuschia, blue, orange, nct, rv]
