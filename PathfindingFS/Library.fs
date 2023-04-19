
namespace PathfindingFS
open Godot

open System
open System.Collections.Generic
//open CommunityToolkit.HighPerformance


module FlowThatShitFS =
    
    let inline randi(limit) =
        int(GD.Randi() % uint32(limit))
        

 
    type CellFS =
        struct
            val position : Vector3i
            val baseCost : byte
            val mutable bestDirection: ValueOption<Vector3i>
            
            val mutable cost : uint16



            new(position,baseCost,bestDirection,cost) = {
                cost = cost
                baseCost = baseCost
                bestDirection = bestDirection
                position = position
            } 

            
            
            new(position,baseCost, cost) = CellFS(position,baseCost,ValueNone,cost)
            new(position,baseCost) = CellFS(position,baseCost,uint16 1)
            
            new(cell:CellFS) = CellFS(cell.position,cell.baseCost,cell.bestDirection,cell.cost) // copy that shit

            
            member self.Position = self.position
            member self.BaseCost = self.baseCost
            member self.BestDirection 
                with get () = self.bestDirection 
                and inline private set bd = self.bestDirection <- bd
            member self.Cost 
                with get () = self.cost 
                and inline private set c = self.cost <- c
                


            
            static member maxPassableCost = System.UInt16.MaxValue - uint16 1
            // methods
            member inline self.CostSum(cell : byref<CellFS>) = (int self.Cost)+(int cell.Cost)
            
            member inline _.ClampCost(cost: int) =
                uint16 (min (int CellFS.maxPassableCost) cost)

            member inline self.AddCellCost(cell: byref<CellFS>) = 
                self.cost = self.ClampCost(self.CostSum(ref cell)) |> ignore
                self
            static member inline Default = CellFS(Vector3i.Zero, byte 1, ValueNone, uint16 1)
        end
    type public Grid = CellFS[,,]
    type public CostField = Grid
    type public IntegrationField = CostField
    type public FlowFieldDone = Vector3i[,,]
    type FlowFieldPhase =
        | Grid of Grid
        | CostField of CostField
        | IntegrationField of IntegrationField
        | Done of FlowFieldDone
        
        
    
    type FlowField(gridSize: Vector3i, target: Vector3i) as this = 
        
        static let directions = [|Vector3i.Left; Vector3i.Right; Vector3i.Down; Vector3i.Up; Vector3i.Forward; Vector3i.Back; // Dir4
             Vector3i.Up + Vector3i.Right;
             Vector3i.Up + Vector3i.Left;
             Vector3i.Up + Vector3i.Forward;
             Vector3i.Up + Vector3i.Back;
             Vector3i.Down + Vector3i.Right;
             Vector3i.Down + Vector3i.Left;
             Vector3i.Down + Vector3i.Forward;
             Vector3i.Down + Vector3i.Back; // Dir8 ends here
             Vector3i.Zero;
        |] // Dir9
        let setCostField(size: Vector3i, target: Vector3i) : CostField = 
            GD.Print "Fucking grid calced again"
            (Array3D.zeroCreate<CellFS> size.x size.y size.z)
                |> Array3D.mapi(fun x y z _ -> 
                    let newPos = Vector3i(x, y, z)
                    let isTarget = newPos = target
                    CellFS(newPos, 
                        byte (if isTarget then 0 else 1), 
                        (if isTarget then ValueSome Vector3i.Zero else ValueNone), 
                        (if isTarget then uint16 0 else System.UInt16.MaxValue)))

        let grid: CostField = setCostField(gridSize,target)
            
            
            
        
        member public _.GridSize : Vector3i = gridSize
        member public _.targetPosition : Vector3i = target
        member public _.Grid : CellFS[,,] = grid


        
        member inline private _.IsWalkablePosition(pos:Vector3i) =
//                    let x y z = pos
                    grid[pos[0],pos[1],pos[2]].BaseCost <> Byte.MaxValue

        member inline private self.GetNeighbors(pos: Vector3i) =
            let upper = Vector3i(
                min pos.x (Array3D.length1 grid),
                min pos.y (Array3D.length2 grid),
                min pos.z (Array3D.length3 grid)
            )

            let lower = Vector3i(
                max 0 pos[0],
                max 0 pos[1],
                max 0 pos[2]
            )
            let sliced = self.Grid[
                lower.x..upper.x,
                lower.y..upper.y,
                lower.z..upper.z
            ]
            for a in sliced do
                GD.Print a
            
            let arr = Array.ofSeq<| (seq {
                for x = lower.x to upper.x do
                for y = lower.y to upper.y do
                for z = lower.z to upper.z do
                    let v = Vector3i(x,y,z)
                    if v <> pos then
                        v
            })
            arr
            
        member inline private self.GetCellAt(grid: inref<Grid>, pos: Vector3i) = grid[pos.x,pos.y,pos.z]



        member self.setIntegrationField(costField: Grid) =

            let openQueue = Queue<Vector3i>()

            openQueue.Enqueue target

            let mutable current = Vector3i.Zero
            while openQueue.TryDequeue &current do

                let mutable currentCell = self.GetCellAt(&costField, current)

                let neighbors = self.GetNeighbors current
                let walkable = seq {
                    
                    for elem in neighbors do
                        if self.IsWalkablePosition elem then elem
                }
                for neighborPos in walkable do
                    let mutable neighborCell = self.GetCellAt(&costField, neighborPos)

                    let newCost =uint16 <| (min ((uint currentCell.Cost) + (uint neighborCell.BaseCost)) (uint CellFS.maxPassableCost))
                    
                    if neighborCell.Cost > newCost then do
                        neighborCell.cost <- neighborCell.ClampCost(neighborCell.CostSum(ref currentCell))
                        self.Grid[neighborPos.x,neighborPos.y,neighborPos.z] = neighborCell
                            |> ignore

                        if not (openQueue.Contains neighborPos) then do
                            openQueue.Enqueue neighborPos
        
        static member public Directions : Vector3i[] = directions

        static member inline Directions4 = FlowField.Directions[0..6]
        static member inline Directions8 = FlowField.Directions[0..14]
        
        

        new() = FlowField (Vector3i.One*4, Vector3i.One)
        new(gridSize) = FlowField(gridSize, 
            Vector3i(
                randi gridSize.x, 
                randi gridSize.y, 
                randi gridSize.z
            )
        )




open FlowThatShitFS

module Say =
    let hello name =
        printfn $"Hello %s{name}"

module Fasz =
    let hello =
        printfn "Hello fasz"
        
module FlowGrid =
    type FlowGrid = {
        gridSize: Vector3i
        targetPosition: Vector3i
        grid: FlowThatShitFS.Grid[,,]
    }
        with
        member _.fityma = 5
    let create size target =
        {
            gridSize = size
            targetPosition = target
            grid = Array3D.zeroCreate size.x size.y size.z
        }
        
            



module here =
    let x = FlowGrid.create (Vector3i.One*4) (Vector3i.One*2)
    