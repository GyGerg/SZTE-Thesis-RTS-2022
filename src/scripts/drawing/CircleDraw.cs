using Godot;
using System;

public partial class CircleDraw : ImmediateMesh
{
    public void DrawEmptyCircle(Vector3 center, float radius)
    {
        var up = Vector3.Up;
        ClearSurfaces();
        SurfaceBegin(PrimitiveType.LineStrip, new Material());

        SurfaceSetUV(Vector2.One);
        SurfaceSetNormal(Vector3.Up);
        SurfaceSetColor(Colors.Green);
        int resolution = 360;
        for (int i = 0; i < resolution; i++)
        {
            var rot = ((float)i / resolution) * Mathf.Tau;
            SurfaceAddVertex(center+(Vector3.Up.Rotated(Vector3.Left, rot)*radius));
        }
        SurfaceEnd();
    }

}
