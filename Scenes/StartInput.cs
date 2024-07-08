using Godot;

public partial class StartInput : SpinBox
{

	[Signal]
	public delegate void ChangedValueEventHandler(float value);

	public override void _Ready()
	{
		ValueChanged += OnValueChanged;
	}

    private void OnValueChanged(double value)
    {
        EmitSignal(nameof(ChangedValue), (float)value);
    }
}
