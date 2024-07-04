using Godot;

namespace Main {

	
	public partial class BeatMaker : Control
	{
		public int LoadPercent = 0;
		public override void _Ready()
		{
		}

		public void LoadEditor()

		{
			CallDeferred("BuildEditor");
		}



		public void BuildEditor()

		{	
			LoadPercent += 100;
			CallDeferred("SetProcess", true);
			CallDeferred("SetProcessInput", true);
		}	

		public override void _Process(double delta)
		{
		}
	}
}

