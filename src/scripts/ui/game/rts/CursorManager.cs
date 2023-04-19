using Godot;
using System;

namespace ThesisRTS.Core;
public partial class CursorManager : Node3D
{
	[Export] private PackedScene heightCursorScene;

	private HeightCursor? instance = null;
	
	
	[Signal]
	public delegate void OnRightClickEventHandler(Vector3 clickPosition);

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}

	private void RemoveCursor(Window? root = null)
	{
		if (instance is null)
		{
			GD.Print("There is no cursor at the moment, returning");
			return;
		}
		
		root ??= GetTree().Root;
		root.RemoveChild(instance);
		instance.QueueFree();
		instance = null;
	}

	private void CreateCursor(Window? root = null)
	{
		root ??= GetTree().Root;
		instance = heightCursorScene.Instantiate<HeightCursor>();
		root.AddChild(instance);
	}

	public override void _Input(InputEvent @event)
	{
		switch (@event)
		{
			case InputEventKey keyEvent:
				switch (keyEvent.Keycode)
				{
					case Key.Ctrl when !keyEvent.Echo:
						if (keyEvent is { Pressed: true, Echo: false })
						{
							var root = GetTree().Root;
							if (instance == null)
								CreateCursor(root);
							else
								RemoveCursor(root);
						}

						break;
					default:
						break;
				}

				break;
			case InputEventMouseButton buttonEvent when instance is not null:
				if (buttonEvent is { Pressed: true, ButtonIndex: MouseButton.Right })
				{
					EmitSignal(SignalName.OnRightClick, instance.ClickVector);
					RemoveCursor();
				}
				break;
		}
	}
}
