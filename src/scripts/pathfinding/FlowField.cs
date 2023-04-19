using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Threading;
using System.Threading.Tasks;
using NoAlloq;
using Godot;

namespace ThesisRTS.Core;
public class FlowField
{
	public readonly Vector3I GridSize;
	private int maxX, maxY, maxZ;
	
	public readonly Cell[,,] Cells;

	public readonly Vector3I TargetPosition;
	
	[Export(PropertyHint.Range, "0,10,")] private float _cellRadius;
	public float CellDiameter => _cellRadius * 2;
	

	private static readonly Vector3I[] DirectionsHorizontal = new Vector3I[]
	{
		Vector3I.Left,
		Vector3I.Left + Vector3I.Forward,
		Vector3I.Left + Vector3I.Back,
		Vector3I.Right,
		Vector3I.Right + Vector3I.Forward,
		Vector3I.Right + Vector3I.Back,
		Vector3I.Forward,
		Vector3I.Back
	};

	private static readonly Vector3I[] DirectionsVertical = new Vector3I[]
	{
		Vector3I.Up,
		Vector3I.Down
	};

	private static T Id<T>(T t) => t; // why is this not built-in

	private static readonly Vector3I[] Directions4 = DirectionsHorizontal
		.Concat(DirectionsVertical).ToArray();
	
	private static readonly Vector3I[] Directions8 = Directions4
		.Concat(DirectionsHorizontal.Select(vec => new []{vec+Vector3I.Up, vec+Vector3I.Down})
			.SelectMany(Id))
		.ToArray();

	private static readonly Vector3I[] Directions9 = Directions8.Append(Vector3I.Zero).ToArray();

	public FlowField(Vector3I size) : this(size,size/2)
	{
        
    }

	public FlowField(Vector3I size, Vector3I target)
	{
		GridSize = size;
		(maxX, maxY, maxZ) = GridSize;
		TargetPosition = target;

        
        int cellsLen = maxX*maxY*maxZ;
        
        Cells = new Cell[maxX,maxY,maxZ];

        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        void CreateCell(int x,int y,int z, in Cell[,,] cells)
        {
	        Cell newCell = new Cell(new Vector3I{X=x,Y=y,Z=z});
	        SetNeighborsOf(ref newCell, Directions9);
	        cells[x,y,z] = newCell;
        }

        if (cellsLen < 4000)
        {
	        for (int x = 0; x < maxX; x++)
	        {
		        for (int y = 0; y < maxY; y++)
		        {
			        for (int z = 0; z < maxZ; z++)
			        {
				        CreateCell(x,y,z,Cells);
			        }
		        }
	        }
        }
        else
        {
	        Parallel.For(0, maxX, x =>
	        {
		        Parallel.For(0, maxY, y =>
		        {
			        Parallel.For(0, maxZ, z =>
			        {
				        CreateCell(x,y,z,Cells);
			        });
		        });
	        });
        }
	}
	

	[MethodImpl(MethodImplOptions.AggressiveInlining)]
	public void GenerateIntegrationField()
	{
		Queue<Vector3I> openQueue = new((int)Mathf.Sqrt(Cells.Length));
		
		Cells[TargetPosition.X,TargetPosition.Y,TargetPosition.Z].SetToTarget();
		openQueue.Enqueue(TargetPosition);

		// using queue instead of list, hope it'll be faster than a list
		while(openQueue.TryDequeue(out Vector3I currentPosition))
		{
			
			Cell current = GetCellAtPosition(currentPosition);
			var dirs = Directions4;
			var neighborList = current.GetNeighbors(dirs);
			for (var i = 0; i < neighborList.Length; i++)
			{
				var neighborPosition = neighborList[i];
				ref Cell neighborCell = ref GetCellAtPosition(neighborPosition);

				if (neighborCell.Cost == byte.MaxValue)
					continue; // skip if it's impassable

				int bCost = (int)neighborCell.Cost + (int)current.BestCost;
				if (bCost < (int)neighborCell.BestCost)
				{
					if (bCost > (int)ushort.MaxValue)
					{
						bCost = ushort.MaxValue;
					}

					neighborCell.BestCost = (ushort)bCost;
					
					openQueue.Enqueue(neighborPosition);
				}
			}
		}
	}

    [MethodImpl(MethodImplOptions.AggressiveOptimization)]
    public void GenerateFlowField()
	{
		var (xLen, yLen, zLen) = GridSize;

		[MethodImpl(MethodImplOptions.AggressiveInlining)]
		void CalculateBestDirection(Cell cell)
		{
			var dspan = Directions9;
			var neighborPositions = GetNeighborsOf(cell);
			for (var i = 0; i < neighborPositions.Length; i++)
			{
				if (dspan[i] == Vector3I.Zero)
					continue;
				
				var neighborPosition = neighborPositions[i];
				ref Cell neighbor = ref GetCellAtPosition(in neighborPosition);

				if (neighbor.BestCost < cell.BestCost)
				{
					cell.BestDirection = neighbor.Position - cell.Position;
					var (x, y, z) = cell.Position;
					Cells[x,y,z] = cell;
				}
			}
		}

		if (GridSize.X * GridSize.Y * GridSize.Z < 4000)
		{
			for (int x = 0; x < xLen; x++)
			for (int y = 0; y < yLen; y++)
			for (int z = 0; z < zLen; z++)
			{
				CalculateBestDirection(Cells[x,y,z]);
			}
		}
		else
		{
			Parallel.For(0, xLen, x =>
				Parallel.For(0, yLen, y =>
					Parallel.For(0, zLen, z =>
					{
						CalculateBestDirection(Cells[x,y,z]);
					})
				)
			);
		}
    }
	
    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    private ref Cell GetCellAtPosition(in Vector3I position) =>
	    ref Cells[position.X,position.Y,position.Z];

    
	private void SetNeighborsOf(ref Cell cell, in ReadOnlySpan<Vector3I> directions)
	{
		var pos = cell.Position;
		for (int i = 0; i < directions.Length; i++)
        {
            Vector3I direction = directions[i];

            Vector3I neighPos = pos + direction;
			
            cell.Neighbors.Set(i, 
	            neighPos.X >= 0 && neighPos.X < maxX 
	                && neighPos.Y >= 0 && neighPos.Y < maxY 
	                && neighPos.Z >= 0 && neighPos.Z < maxZ);
        }
	}


	public ReadOnlySpan<Cell> GetNeighborsOf(in Vector3I position, in ReadOnlyMemory<Vector3I> directions) => GetNeighborsOf(Cells[position.X,position.Y,position.Z], directions);
	public ReadOnlySpan<Cell> GetNeighborsOf(in int x, in int y, in int z, in ReadOnlyMemory<Vector3I> directions) => GetNeighborsOf(Cells[x,y,z], directions);


	private ReadOnlySpan<Cell> GetNeighborsOf(in Cell cell, in ReadOnlyMemory<Vector3I> directions)
	{
		var neighbors = cell.GetNeighbors(in directions);
		int nLen = neighbors.Length;
		Span<Cell> neighborCells = new(new Cell[nLen]);
		neighborCells = neighbors.Select(vec => GetCellAtPosition(vec)).ConsumeInto(neighborCells);

		return neighborCells;
	}

	public ref Cell GetCellFromWorldPos(Vector3 position)
	{
		var sizeVec = new Vector3(GridSize.X, GridSize.Y, GridSize.Z);
		var percent = position / (sizeVec * CellDiameter);

		percent = percent.Clamp(Vector3.Zero, Vector3.One) * GridSize;
		percent = percent.Floor();


		var (x, y, z) = percent.Clamp(Vector3.Zero, sizeVec - Vector3.One);
		// return ref grid[(int)x][(int)y][(int)z];
		return ref Cells[(int)x, (int)y, (int)z];
	}

	[MethodImpl(MethodImplOptions.AggressiveInlining)]
	private static ReadOnlySpan<Vector3I> GetNeighborsOf(in Cell cell)
	{
		return cell.GetNeighbors(Directions8);
	}

}
