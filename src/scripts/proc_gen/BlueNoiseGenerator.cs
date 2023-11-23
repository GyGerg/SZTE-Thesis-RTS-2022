using System;
using System.Collections.Generic;
using System.Linq;
using Godot;

// namespace SZTEThesisRTS2022.ProcGen;

[GlobalClass]
public partial class BlueNoiseGenerator : Resource
{

	[Signal]
	public delegate void GenerationDoneEventHandler(Godot.Collections.Dictionary<Vector2,Vector2[]> chunks);

	private static readonly StringName genDoneName = "GenerationDone";
	[Export] private int SectorSizeInUnits = 2000;

	[Export] private int SectorCountAxis = 4;

	[Export] private float density = 3;

	[Export(PropertyHint.Range, "0.0,1")] private float sectorMarginProportion = .1f;
	[Export(PropertyHint.Range, "0.0,1")] private float subSectorMarginProportion = .1f;

	private int cellWidth;

	private int subSectorCount;

	private float sectorMargin;

	private float subsectorBaseSize;

	private float subsectorMargin;

	private float subsectorSize;

	private float halfSectorSize;

	private int halfSectorCount;

	private Dictionary<Vector2, Vector2[]> chunks = new();

	private readonly RandomNumberGenerator rng = new();

	private const string StartSeed = "try_me_lmao";

	public Dictionary<Vector2, Vector2[]> DictInit()
	{
		cellWidth = Mathf.CeilToInt(Mathf.Sqrt(density));
		subSectorCount = cellWidth * cellWidth;
		sectorMargin = SectorSizeInUnits * sectorMarginProportion;
		subsectorBaseSize = (SectorSizeInUnits - sectorMargin * 2) / cellWidth;
		subsectorMargin = subsectorBaseSize * subSectorMarginProportion;
		subsectorSize = subsectorBaseSize - subsectorMargin * 2;

		halfSectorSize = (float)SectorSizeInUnits / 2;
		halfSectorCount = SectorCountAxis / 2;

		return new(halfSectorCount * halfSectorCount);
	}

	public Godot.Collections.Dictionary<Vector2,Vector2[]> Generate(int sectorCount)
	{
		SectorCountAxis = sectorCount;
		chunks = DictInit();
		if (halfSectorCount > 0)
		{
			for (int x = -halfSectorCount; x < halfSectorCount+1; x++)
			for (int y = -halfSectorCount; y < halfSectorCount+1; y++)
			{
				GenerateChunk(x, y, chunks);
			}
		}
		else
		{
			GenerateChunk(0, 0, chunks);
		}
		
		chunks.TrimExcess();
		var ret = new Godot.Collections.Dictionary<Vector2, Vector2[]>(chunks);
		EmitSignal(genDoneName, ret);
		return new(ret);
	}

	private Vector2[] GenerateChunk(int x, int y, Dictionary<Vector2,Vector2[]> chunks)
	{
		rng.Seed = $"{StartSeed} {x} {y}".Hash();
		Vector2 sectorTopLeft = new(
			x * SectorSizeInUnits - halfSectorSize + sectorMargin,
			y * SectorSizeInUnits - halfSectorSize + sectorMargin
		);
		Vector2[] sectorData = new Vector2[(int)density];
		var sectorIndices = Enumerable
			.Range(0, subSectorCount)
			.OrderBy(Random.Shared.Next)
			.ToList();

		for (int i = 0; i < density; i++)
		{
			int _x = sectorIndices[i] / cellWidth;
			int _y = sectorIndices[i] - _x * cellWidth;
			sectorData[i] = GenerateRandomPosition(new Vector2(
				_x, 
				_y), sectorTopLeft);
		}
		
		chunks.Add(new(x,y), sectorData);

		return sectorData;
	}

	private Vector2 GenerateRandomPosition(Vector2 coord, Vector2 sectorTopLeft)
	{
		Vector2 subsectorTopLeft =
			sectorTopLeft
			+ (new Vector2(subsectorBaseSize, subsectorBaseSize) * coord)
			+ new Vector2(subsectorMargin, subsectorMargin);
		Vector2 subsectorBotRight = subsectorTopLeft + (Vector2.One * subsectorSize);

		return new(
			rng.RandfRange(subsectorTopLeft.X, subsectorBotRight.X),
			rng.RandfRange(subsectorTopLeft.Y, subsectorBotRight.Y)
		);

	}
}