using Godot;
using Coll = Godot.Collections;
using System;
using System.Linq;
using System.Collections.Generic;

namespace ThesisRTS.AI;

public partial class AIPath : RefCounted
{
    public bool isOpen;
    public double pathLength;

    private List<PathSegment> segments;

    Vector3 nearestPointOnPath;
    Vector3 nearestPointOnSegment;

    public AIPath(Coll.Array<Vector3> waypoints, bool is_open = false) : base()
    {
        isOpen = is_open;
        CreatePath(waypoints);
        nearestPointOnPath = nearestPointOnSegment = waypoints[0];
        segments = new List<PathSegment>();
        
    }

    public void CreatePath(Coll.Array<Vector3> waypoints)
    {
        
        if(waypoints is not { Count: > 1})
        {
            GD.PrintErr("Waypoints must contain at least 2 waypoints.");
            return;
        }
        var span = new Span<Vector3>(waypoints.ToArray());

        pathLength = 0;

        segments = new List<PathSegment>();

        var current = span[0];
        Vector3 previous;

        int cnt = span.Length;
        for (int i = 0; i <= cnt; i++)
        {
            previous = current;

            if(i < cnt)
                current = waypoints[i];
            else if(isOpen)
                break;
            else
                current = waypoints[0];

            var segment = new PathSegment(previous, current, pathLength);
            pathLength += segment.length;
            segments.Add(segment);
        }
    }

    double CalculateDistance(Vector3 AgentCurrentPosition)
    {
        if (segments.Count == 0)
            return 0;

        var smallestDistanceSquared = double.PositiveInfinity;
        PathSegment nearestSegment = default;
        for (int i = 0; i < segments.Count; i++)
        {
            
            PathSegment seg = segments[i];
            double distanceSquared = CalculatePointSegmentDistanceSquared(seg.begin, seg.end, AgentCurrentPosition);
            if(distanceSquared < smallestDistanceSquared)
            {
                nearestPointOnPath = nearestPointOnSegment;
                smallestDistanceSquared = distanceSquared;
                nearestSegment = seg;
            }
        }
        
        return nearestSegment.cumulativeLength - nearestPointOnPath.DistanceTo(nearestSegment.end);
    }
    Vector3 GetStartPoint() => segments[0].begin;
    Vector3 GetEndPoint() => segments[^0].end;

    double CalculatePointSegmentDistanceSquared(Vector3 start, Vector3 end, Vector3 position)
    {
        nearestPointOnSegment = start;
        var startToEnd = end - start;
        var startToEndLengthSquared = startToEnd.LengthSquared();
        if(startToEndLengthSquared > 0.000001)
        {
            var t = (position - start).Dot(startToEnd) / startToEndLengthSquared;
            nearestPointOnSegment += startToEnd * Mathf.Clamp(t, 0, 1);
        }
        return nearestPointOnSegment.DistanceSquaredTo(position);
    }
}