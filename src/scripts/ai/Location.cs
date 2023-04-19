using Godot;

namespace ThesisRTS.AI
{

    internal interface IReadOnlyLocation
    {
        Vector3 Position { get; }
        Quaternion Orientation { get; }
    }
    internal interface ILocation : IReadOnlyLocation
    {
        new Vector3 Position { get; set; }
        new Quaternion Orientation { get; set; }
    }
    internal struct Location : ILocation
    {
        public Vector3 Position { get; set; }
        public Quaternion Orientation { get; set; }

        public Location(Vector3 position, Quaternion orientation)
        {
            Position = position;
            Orientation = orientation;
        }
    }

    public readonly struct PathSegment
    {
        public readonly Vector3 begin;
        public readonly Vector3 end;
        public readonly double length;
        public readonly double cumulativeLength;

        public PathSegment(Vector3 begin, Vector3 end, double lengthBefore = 0)
        {
            this.begin = begin;
            this.end = end;
            length = begin.DistanceTo(end);
            cumulativeLength = lengthBefore + this.length;
        }
    }
}
