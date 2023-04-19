using Godot;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using NoAlloq;


namespace ThesisRTS.Core;
public partial class SelectUnitsControl : Control
{
	private static readonly int RAY_LENGTH = 1000;
	private static readonly StringName GroupUnits = new("units");

	private bool dragging = false;

	[Signal]
	public delegate void OnSelectedUnitsChangedEventHandler(int amount);
	private Node3D[] _selectableUnits;

	private Color[] _colorsArr = new Color[]
	{
		Colors.Red - Color.Color8(0, 0, 0, 80),
		Colors.Green - Color.Color8(0, 0, 0, 80)
	};
	private Vector2 _mousePosition = Vector2.Zero;
	
	private Vector2 dragStart = Vector2.Zero;
	private Vector3 _dragStartGlobal = Vector3.Zero;
	private float _dragProjectDistance = 0f;

	private RectangleShape2D selectionBox = new();

    //private Unit[] selectedUnits = Array.Empty<Unit>();
    private Memory<Node3D> selectedUnits = Array.Empty<Node3D>();


    private Viewport _viewport;

	private Camera3D _cam;

	[Export] private MultiMeshInstance3D _multiMesh;
	private PhysicsDirectSpaceState3D _currentSpaceState = default!;
	private MultiMesh _mm;
	ConvexPolygonShape3D shape = new ConvexPolygonShape3D();



	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		_mm = _multiMesh.Multimesh;
		_viewport = GetViewport();
		_cam = _viewport.GetCamera3D();
		var handle = typeof(SelectUnitsControl).GetMethod(nameof(SelectUnits))?.MethodHandle;
		
		if (handle is null) return;
		for (int i = 0; i < 1000; i++)
		{
			RuntimeHelpers.PrepareMethod(handle.Value);
		}

	}
	
	private void SetMouseTargetBox()
	{
		var viewport = _viewport;
		var cam = _cam;
		var spaceState = _currentSpaceState;

		var (start, end) = (dragStart, _mousePosition);
		if (start.DistanceSquaredTo(end) < 16)
			return;
		var st3d = new Vector3(start.X, 0, start.Y);
		var e3d = new Vector3(end.X, 0, end.Y);
		var points = new Vector3[]
		{
			cam.ProjectPosition(start,0),
			cam.ProjectPosition(new Vector2(start.X,end.Y),0),
			cam.ProjectPosition(end, 0),
			cam.ProjectPosition(new Vector2(end.X,start.Y),0),
			
			cam.ProjectPosition(start,100),
			cam.ProjectPosition(new Vector2(start.X,end.Y),100),
			cam.ProjectPosition(end, 100),
			cam.ProjectPosition(new Vector2(end.X,start.Y),100),
		};
		var convex = PhysicsServer3D.ConvexPolygonShapeCreate();
		PhysicsServer3D.ShapeSetData(convex, points);
		shape.Points = points;
		
		shape = new ConvexPolygonShape3D { Points = points };
		
		if (points.Length == 0)
		{
			GD.PrintErr("No points in shape");
			var arr = PhysicsServer3D.ShapeGetData(convex).As<Godot.Collections.Array<Vector3>>();
			GD.Print(arr);
			return;
		}
		Godot.Collections.Array<Godot.Collections.Dictionary> result;
		try
		{
			GD.Print("Calling intersectshape, Rid: ", convex);
			result = spaceState.IntersectShape(maxResults: 512, parameters: new PhysicsShapeQueryParameters3D
			{
				ShapeRid = convex,
				CollideWithAreas = false,
				CollideWithBodies = true,
				CollisionMask = 1,
				Transform = Transform3D.Identity
			});
		}
		catch (Exception e)
		{
			Console.WriteLine(e.Message);
			result = new();
		}
		PhysicsServer3D.FreeRid(convex);
		GD.Print("intersectShape done");
		GD.Print($"Collided with: {result?.Count ?? 0}");
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		_mousePosition = _viewport.GetMousePosition();

		QueueRedraw(); // we somehow have to force a control's redraw, since these sh*ts thankfully don't try to redraw themselves once per frame for no reason
		int len = _mm.VisibleInstanceCount = selectedUnits.Length;
		for (int i = 0; i < len; i++)
		{
			Transform3D newTrans =
				new Transform3D(new Basis(Quaternion.Identity), selectedUnits.Span[i].GlobalPosition);
			_mm.SetInstanceTransform(i,newTrans);
			_mm.SetInstanceColor(i, _colorsArr[0]);
		}
	}

	public override void _PhysicsProcess(double delta)
	{
		_currentSpaceState = _viewport.World3D.DirectSpaceState;
		if (dragging/* && dragStart != mousePos*/)
		{
			// SetMouseTargetBox();
			SelectUnits(_mousePosition); // < 1 msec with 288 (copypaste node vibes) selectable units AND with Linq usage, which is/was known for its slowness
		}
	}

	public override void _Draw()
	{
		var mousePos = _viewport.GetMousePosition();
		dragStart = _cam.UnprojectPosition(_dragStartGlobal);
		if (dragging && dragStart != mousePos)
		{
			var start = dragStart;
			var end = mousePos;
			if (start.X > end.X)
				(start.X, end.X) = (end.X, start.X);
			if (start.Y > end.Y)
				(start.Y, end.Y) = (end.Y, start.Y);


			var color = Colors.Green;
			var rect = new Rect2(start, (end - start));
			color.A = 0.3f;
			DrawRect(rect, color, filled: false, width: 2f);
			color.A = 0.1f;
			DrawRect(rect, color, filled: true);
			
		}
		for (int i = 0; i < selectedUnits.Length; i++)
		{
			//var unit = selectedUnits[i];
		}
	}

	public override void _UnhandledInput(InputEvent @event)
	{
		var mousePos = _viewport.GetMousePosition();
		if (@event is InputEventMouseButton mouseEvent)
		{
			switch (mouseEvent.ButtonIndex)
			{
				case MouseButton.Left when mouseEvent.IsPressed():
					GD.Print("Started dragging");
					_dragStartGlobal = _cam.ProjectPosition(mouseEvent.Position, _dragProjectDistance);
					dragStart = mouseEvent.GlobalPosition;
					dragging = true;
					break;
				case MouseButton.Left:
					GD.Print("Stopped dragging");
					SelectUnits(mousePos);
					dragStart = Vector2.Zero;
					dragging = false;
					break;
				default:
					break;
			}
		}
	}

	[MethodImpl(MethodImplOptions.AggressiveOptimization)]
	private void SelectUnits(Vector2 mousePos)
	{
		System.Diagnostics.Stopwatch watch = new();
		watch.Start();
		//Unit[] newSelectedUnits = Array.Empty<Unit>();
		Memory<Node3D> newSelectedUnits;
        if (mousePos.DistanceSquaredTo(dragStart) < 16 && TryGetUnitUnderMousePosition(mousePos, out var unit))
		{
			newSelectedUnits = new[] { unit! };	// method would return false if it can't find a unit
		}
		else
		{
			newSelectedUnits = GetUnitsInBox(dragStart, mousePos);
		}

		
		// todo: unit select behav
		
		selectedUnits = newSelectedUnits.Span.ToArray();
		
		watch.Stop();
		EmitSignal(SignalName.OnSelectedUnitsChanged, selectedUnits.Length);
	}
	/// <summary>
	/// Szoveg
	/// </summary>
	/// <param name="mousePos">
	///		Current mouse position, can be extracted from an <see cref="InputEventMouseButton"/> or through a <see cref="Viewport"/>'s <see cref="Viewport.GetMousePosition"/> method.
	/// </param>
	/// <param name="result">
	///		The <see cref="Node3D"/> (will be changed to more specific types) where our method should assign our result, or <b>null</b> if the <see cref="RayCast3D"/> didn't hit a valid object.
	/// </param>
	/// <returns><b>True</b> if the <see cref="RayCast3D"/> found a collider with a <see cref="Node3D"/>, otherwise <b>false</b>.</returns>
	private bool TryGetUnitUnderMousePosition(Vector2 mousePos, out Node3D? result)
	{
		result = null;
		var rayResult = RaycastFromMouse(mousePos, 3);

		if (rayResult.Count != 0 && rayResult.TryGetValue("collider", out Variant collider) && collider.Obj is Node3D node && !_cam.IsPositionBehind(node.GlobalPosition))
		{
			if (node.IsInGroup("units") || node.IsInGroup("is_selected"))
				return false;
			result = node;
			return true;
		}

		return false;
	}
	[MethodImpl(MethodImplOptions.AggressiveOptimization)]
	private Memory<Node3D> GetUnitsInBox(Vector2 topLeft, Vector2 bottomRight)
	{
		var cam = _cam;
		Vector2 tl = new Vector2(Mathf.Min(topLeft.X, bottomRight.X), Mathf.Min(topLeft.Y, bottomRight.Y));
		Vector2 br = new Vector2(Mathf.Max(topLeft.X, bottomRight.X), Mathf.Max(topLeft.Y, bottomRight.Y));
		// if (topLeft.X > bottomRight.X)
		// {
		// 	(topLeft.X, bottomRight.X) = (bottomRight.X, topLeft.X);
		// }
		// if (topLeft.Y > bottomRight.Y)
		// {
		// 	(topLeft.Y, bottomRight.Y) = (bottomRight.Y, topLeft.Y);
		// }


		// var box = new Rect2(topLeft, bottomRight - topLeft);
		var box = new Rect2(tl, br - tl);
		
		return _selectableUnits.Where(unit =>
			{
				return box.HasPoint(cam.UnprojectPosition(unit.GlobalPosition));
			}

		).ToArray();
	}

	/// <summary>
	/// <seealso cref="PhysicsDirectSpaceState3D.IntersectRay">asd</seealso>
	/// <br/>-----IntersectRay doc for return value-----<br/>
	/// <inheritdoc cref="PhysicsDirectSpaceState3D.IntersectRay"/>
	/// </summary>
	/// <param name="mousePos">Current global mouse position</param>
	/// <param name="collisionMask"></param>
	/// <returns></returns>
	[MethodImpl(MethodImplOptions.AggressiveInlining)]
	private Godot.Collections.Dictionary RaycastFromMouse(Vector2 mousePos, uint collisionMask)
	{
		Vector3 rayStart = _cam.ProjectRayOrigin(mousePos);
		Vector3 rayEnd = rayStart + (_cam.ProjectRayNormal(mousePos) * RAY_LENGTH);
		
		var spaceState = _currentSpaceState;
		GD.Print($"spaceState is: {spaceState?.GetType().ToString() ?? "none"}");
		return spaceState!.IntersectRay(new PhysicsRayQueryParameters3D()
		{
			From = rayStart,
			To = rayEnd,
			CollisionMask = collisionMask,
			Exclude = new Godot.Collections.Array<Rid>()
		});
	}

	public void MoveSelectedUnitsTowards(Vector3 globalPos)
	{
		var target = new Transform3D(new Basis(Quaternion.Identity), globalPos);
		StringName setTarget = "set_target";
		foreach (var unit in selectedUnits.Span)
		{
			unit.Call(setTarget, globalPos);
		}
	}
	
	public void OnCameraDistanceChanged(float newDistance)
	{
		_dragProjectDistance = newDistance;
	}

	public void OnSceneDoneInstancing()
	{
		_selectableUnits = GetTree().GetNodesInGroup("units").Select(x => (x as Node3D)!)
			.Where(x => x.HasNode("Selectable")).ToArray();
		_mm.InstanceCount = _selectableUnits.Length;
	}
}
