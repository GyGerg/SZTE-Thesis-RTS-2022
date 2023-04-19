using Godot;
using System;

namespace ThesisRTS.Core;
public partial class HeightCursor : MeshInstance3D
{
	[Export] private Vector3 currentPosition = Vector3.Zero;
	[Export] private Node3D heightMesh, mouseMesh;
	private Material material = new();
	private static readonly StringName UpdateCursorName = new("update_cursor");
	public Vector3 CurrentPosition
	{
		get => currentPosition;
		private set
		{
			currentPosition = value;
			GlobalPosition = currentPosition;
		}
	}
	[Export] private float currHeight = 0f;
	private Vector3? startPosition;

	public float CurrHeight
	{
		get => currHeight;
		private set
		{
			currHeight = value;
			if(sphere != null) sphere.Position = -Vector3.Up * value;
		}
	}

	public Vector3 ClickVector => heightMesh.GlobalPosition;
	private Vector2 rayOffset = Vector2.Zero;
	private Vector2 posOffset = Vector2.Zero;

	/// set in MouseMotion stuff
	private Vector2 mouseRelative = Vector2.Zero;

	private Vector3 RightClickPosition => GlobalPosition;

	[Export(PropertyHint.Range, "(10,30,1)")]
	private float heightSensitivity = 10;

	[Export] private bool isShiftPressed;

	private Node3D? sphere;

	private Viewport viewport = default!;
	private Camera3D cam = default!;
	private World3D world = default!;
	private PhysicsDirectSpaceState3D? _currentSpaceState;


	public override async void _Ready()
	{
		sphere = GetNode<Node3D>("mouseSphere");
		viewport = GetViewport();
		cam = viewport.GetCamera3D();
		world = GetWorld3D();

		
		
		var mousePos = viewport.GetMousePosition();
	}

	

	private Godot.Collections.Dictionary Get3DMousePositionFlat(Vector2 mousePosition)
	{

		return _currentSpaceState?.IntersectRay(new PhysicsRayQueryParameters3D
		{
			From = cam.ProjectRayOrigin(mousePosition),
			To = cam.ProjectRayNormal(mousePosition) * 1000,
			CollideWithAreas = true,
			CollideWithBodies = false,
			CollisionMask = 128
		}) ?? new();
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		
		if(Mesh.HasMethod(UpdateCursorName) && startPosition.HasValue)
			Mesh.Call(UpdateCursorName, heightMesh.Position, mouseMesh.Position, (startPosition.Value - Position));
		// heightMesh.Mesh.Call("_process", delta);
		// mouseMesh.Mesh.Call("_process", delta);
	}

	public override void _PhysicsProcess(double delta)
	{
		_currentSpaceState = world.DirectSpaceState;
		var ray = Get3DMousePositionFlat(viewport.GetMousePosition());
		
		startPosition ??= CurrentPosition = ray.TryGetValue("position", out var pos) ? pos.AsVector3() : Vector3.Zero;

		if (ray.TryGetValue(Node3D.PropertyName.Position, out var np) && np.VariantType == Variant.Type.Vector3)
		{
			var newPos = np.AsVector3();
			if (isShiftPressed)
			{
				var relYPercent = mouseRelative.Y / GetViewport().GetVisibleRect().Size.Y;
				CurrHeight -= relYPercent * heightSensitivity;
				CurrentPosition = new Vector3(currentPosition.X, currHeight, currentPosition.Z); //horizontal plane, old value, vertical, new value
			}
			else // got a value on the horizontal plane
			{
				CurrentPosition = new Vector3(newPos.X, currHeight, newPos.Z); // horizontal plane, new value, vertical, old value
			}
		}
		base._PhysicsProcess(delta);
	}

	public void ResetState(Vector3 position)
	{
		CurrentPosition = position;
		CurrHeight = 0f;
	}

	public override void _Input(InputEvent @event)
	{
		switch (@event)
		{
			case InputEventMouseMotion motion:
				mouseRelative = motion.Relative;

				break;
			case InputEventKey key:
			{
				switch (key.Keycode)
				{
					case Key.Shift:
						if(!key.Echo)
						{
							isShiftPressed = key.Pressed;
							
							Input.WarpMouse(cam.UnprojectPosition(CurrentPosition));
						}
						break;
				}
				break;
			}
			default:
				break;
		}
	}
}
