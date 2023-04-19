using Godot;
using System;
using System.Diagnostics.CodeAnalysis;
using ThesisRTS.Core;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;

public partial class FlowFieldTrial : Node3D
{
	[Export] private Vector3I gridSize = new(4, 4, 4);
	[Export] private Vector3I targetPosition = new(2, 2, 2);
	[Export(PropertyHint.Range, "0,10,")] private float cellRadius;
	// Called when the node enters the scene tree for the first time.
	private FlowField flowField;
	
	[Export] private PackedScene _nodeScene;
	[Export] private PackedScene _ballScene;
	private Node3D[] _arrows;
	private Node3D _ball;

	[MemberNotNull(nameof(flowField))]
	public override async void _Ready()
	{
		var scn = _nodeScene;
		var ball = _ballScene;
		int cnt = 0;
		_arrows = new Node3D[gridSize.X * gridSize.Y * gridSize.Z];
		for (int x = 0; x < gridSize.X; x++)
		{
			for (int y = 0; y < gridSize.Y; y++)
			{
				for (int z = 0; z < gridSize.Z; z++)
				{
					_arrows[cnt] = scn.Instantiate<Node3D>();
					_arrows[cnt].Position = new Vector3(x*cellRadius, y*cellRadius, z*cellRadius);
					AddChild(_arrows[cnt]);
					++cnt;
				}
			}
		}

		_ball = ball.Instantiate<Node3D>();
		_ball.Position = new Vector3(targetPosition.X,targetPosition.Y,targetPosition.Z) * cellRadius;
		AddChild(_ball);
	}

	public override void _UnhandledInput(InputEvent @event)
	{
		if (@event is InputEventMouseButton { Pressed: true } mouseEvt)
		{
			switch(mouseEvt.ButtonIndex)
			{
				case MouseButton.Right:
					_ = BenchmarkFlowFieldCS();
					break;
				default:
					break;
			}

		}
	}
	private async Task<int> BenchmarkFlowFieldCS()
	{
		Stopwatch taskWatch = new();
		taskWatch.Start();
		await Task.Run(() =>
		{
			Stopwatch watch = new();
			watch.Start();
			flowField = new FlowField(gridSize, targetPosition);
			//flowField.GenerateCostField();
			watch.Stop();
			GD.Print(
				$"{nameof(BenchmarkFlowFieldCS)}: CostField generation took {watch.ElapsedTicks / (Stopwatch.Frequency / (1000L * 1000L))}us");
			watch.Restart();
			flowField.GenerateIntegrationField();
			watch.Stop();
			GD.Print(
				$"{nameof(BenchmarkFlowFieldCS)}: IntegrationField generation took {watch.ElapsedTicks / (Stopwatch.Frequency / (1000L * 1000L))}us");
			watch.Restart();
			flowField.GenerateFlowField();
			watch.Stop();
			GD.Print(
				$"{nameof(BenchmarkFlowFieldCS)}: FlowField generation took {watch.ElapsedTicks / (Stopwatch.Frequency / (1000L * 1000L))}us");
		});
		taskWatch.Stop();
		GD.Print($"Task took {taskWatch.ElapsedTicks / (Stopwatch.Frequency / (1000L * 1000L))}us");
		
		for (int x = 0, i = 0; x < gridSize.X; x++)
		{
			for (int y = 0; y < gridSize.Y; y++)
			{
				for (int z = 0; z < gridSize.Z; z++)
				{
					Cell currCell = flowField.Cells[x, y, z];
					
					_arrows[i].Visible = currCell.BestDirection != Vector3I.Zero;
					if (_arrows[i].Visible)
					{
						var bestDir = currCell.BestDirection;
						var (xi, yi, zi) = bestDir;
						var lookVector = new Vector3
						{
							X = xi,
							Y = yi,
							Z = zi
						};
						// if (currCell.BestDirection == Vector3I.Up || currCell.BestDirection == Vector3I.Down)
						// {
						// 	GD.Print(currCell.BestDirection);
						// 	var nextPos = currCell.Position + currCell.BestDirection;
						// 	GD.Print(flowField._cells[nextPos.X,nextPos.Y,nextPos.Z].Position);
						// }

						var newTrans = _arrows[i].GlobalTransform
							.LookingAt(_arrows[i].GlobalPosition + (lookVector * cellRadius), Vector3.Up);
						_arrows[i].GlobalTransform = newTrans;
						_arrows[i].Scale = Vector3.One;
					}
					++i;
				}
			}
		}
		GD.Print($"{nameof(BenchmarkFlowFieldCS)}: GridSize: {flowField.GridSize}, Target: {flowField.TargetPosition}");
		return 0;
	}
}
