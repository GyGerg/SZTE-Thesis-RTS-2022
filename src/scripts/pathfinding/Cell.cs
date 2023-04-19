using System.Collections;

namespace ThesisRTS.Core;

using System;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using Num = System.Numerics;
using Godot;
public struct Cell : IEquatable<Cell?>, IEquatable<Cell>
{
	[MethodImpl(MethodImplOptions.AggressiveInlining)]
	public bool Equals(Cell? other)
	{
		return other is not null && Equals(other.Value);
	}

	[MethodImpl(MethodImplOptions.AggressiveInlining)]
	public bool Equals(Cell other) => Position == other.Position && _baseCost == other._baseCost;

	public override int GetHashCode()
	{
		return HashCode.Combine(Position, _baseCost);
	}
	public readonly Vector3I Position;
	// public readonly Dictionary<Vector3I, Vector3I> Neighbors;
	public readonly BitArray Neighbors;
	public byte Cost;
	private readonly byte _baseCost;
	public ushort BestCost;
	public Vector3I BestDirection;

	public void SetToTarget()
	{
		if (_baseCost == byte.MaxValue || Cost == 0)
			return;
		Cost = 0;
		BestCost = 0;
	}

	public readonly ReadOnlySpan<Vector3I> GetNeighbors(in ReadOnlyMemory<Vector3I> directions)
	{
		int len = directions.Length;
		Span<Vector3I> arr = stackalloc Vector3I[directions.Length];
		
		int size = 0;

		for (int i = 0; i < len; i++)
		{
			if (Neighbors.Get(i))
			{
				var newVec = (directions.Span[i] + Position);
				arr[size] = newVec;
				++size;
			}
		}
		return arr[..size].ToArray();

	}

	public Cell(Vector3I position, bool isImpassable = false)
	{
		Neighbors = new BitArray(64);
		Position = position;

		Cost = isImpassable ? byte.MaxValue : (byte)1;
		_baseCost = Cost;
		BestCost = ushort.MaxValue;
		BestDirection = Vector3I.Zero;
	}

	public override bool Equals(object? obj)
	{
		return obj is Cell cell && Equals(cell);
	}

	public static bool operator ==(Cell left, Cell right)
	{
		return left.Equals(right);
	}

	public static bool operator !=(Cell left, Cell right)
	{
		return !(left == right);
	}
}
