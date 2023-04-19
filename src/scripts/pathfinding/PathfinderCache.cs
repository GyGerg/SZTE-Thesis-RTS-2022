using System;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using Godot;

namespace ThesisRTS.Core;

public partial class PathfinderCache : Node
{
    private readonly Dictionary<PathCacheKey, FlowField> _flowFields;
    [Export] private int chunkSize = 8;
    public PathfinderCache()
    {
        _flowFields = new Dictionary<PathCacheKey, FlowField>();
    }

    public FlowField GetFlowField(PathCacheKey key, Vector3I targetPosition)
    {
        if ((float)chunkSize / key.Radius != 0f)
            throw new ArgumentException("ChunkSize must be divisible by key's Radius", $"{nameof(key)}.{nameof(key.Radius)}");

        var fromTo = key.To-key.From;

        var fromToStep = key.From + fromTo.Sign();
        
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        FlowField GetOrGenerateFlowField(PathCacheKey nk, Vector3I tp)
        {
            Vector3I ft = nk.To - nk.From;
            if (_flowFields.TryGetValue(nk, out FlowField? rt)) return rt;
            Vector3I gridSize = new Vector3I
            {
                X = (int)(chunkSize / nk.Radius) * Mathf.Max(1,Mathf.Abs(ft.X)),
                Y = (int)(chunkSize / nk.Radius) * Mathf.Max(1,Mathf.Abs(ft.Y)),
                Z = (int)(chunkSize / nk.Radius) * Mathf.Max(1,Mathf.Abs(ft.Z)),
            };
            var newField = new FlowField(gridSize, tp);
            newField.GenerateIntegrationField();
            newField.GenerateFlowField();
                
            _flowFields.Add(nk, newField);
            rt = newField;

            return rt;
        }

        if (fromTo.Sign() != fromTo) // 0, 1, -1-only val check
        {
            return GetOrGenerateFlowField(key with { To = key.From + fromTo.Sign() },
                targetPosition);
        }

        return GetOrGenerateFlowField(key, targetPosition); 
    }
    
}

public readonly record struct PathCacheKey(Vector3I From, Vector3I To, float Radius=1);