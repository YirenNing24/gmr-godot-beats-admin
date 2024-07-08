using Godot;
using Array = Godot.Collections.Array;

public partial class BpmInput : SpinBox
{	
	[Signal]
	public delegate void TempoChangedEventHandler(float value);

	private float tempoMeterTime = 0;
	private bool tempoMeterStarted = false;
	private Array tempoMeterValues = new();

	public override void _Ready()
	{
		SetProcess(true);
		ValueChanged += OnValueChanged;
	}

	public override void _Process(double delta)
	{
		if (tempoMeterStarted)
		{
			tempoMeterTime += (float)delta;
			if (tempoMeterTime > 1.5f)
			{
				tempoMeterStarted = false;
			}
		}
	}

	private void OnValueChanged(double value)
	{
		EmitSignal(nameof(TempoChanged), (float)value);
	}

	public float GetTempo()
	{
		return (float)Value;
	}

	public void SetTempo(float value)
	{
		Value = value;
	}
}
