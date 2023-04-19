namespace PathfindingFS
// open Godot
// open System.Collections.Generic


// module public FlowfieldFS =
    
//     let inline randi(limit) =
//         int(GD.Randi() % uint32(limit))

//     type public Cell(position: Vector3i, baseCost: byte, bestDirection: Option<Vector3i>, cost: uint16) = 
//         struct
//             member _.Position = position
//             member _.BaseCost = baseCost
//             member _.BestDirection = bestDirection
//             member _.Cost = uint16 System.UInt16.MaxValue
            
//             static member maxPassableCost = System.UInt16.MaxValue - uint16 1
//             // methods
//             member inline x.CostSum(cell : byref<Cell>) = (int x.Cost)+(int cell.Cost)
            
//             member inline _.ClampCost(cost: int) =
//                 uint16 (min (int Cell.maxPassableCost) cost)

//             member inline x.AddCellCost(cell: byref<Cell>) = Cell(x.Position, x.BaseCost, x.BestDirection, x.ClampCost(x.CostSum(ref cell)))
//             static member inline Default = Cell(Vector3i.Zero, byte 1, None, uint16 1)
            
//         end

//     type FlowField(gridSize: Vector3i, target: Vector3i) = 

//         member _.grid : Cell[,,] = 
//             (Array3D.zeroCreate<Cell> gridSize.x gridSize.y gridSize.z)
//             |> Array3D.mapi(fun x y z _ -> 
//                 let newPos = Vector3i(x, y, z)
//                 Cell(newPos, byte 1, (if newPos = target then Some Vector3i.Zero else None), (if newPos = target then uint16 0 else uint16 1)))
        
//         member inline private self.IsWalkablePosition(pos:Vector3i) =
//                     self.grid[pos.x,pos.y,pos.z].BaseCost <> System.Byte.MaxValue

//         member inline private self.GetNeighbors(pos: Vector3i) =
//             let upper = Vector3i(
//                 min pos.x (Array3D.length1 self.grid),
//                 min pos.y (Array3D.length2 self.grid),
//                 min pos.z (Array3D.length3 self.grid)
//             )

//             let lower = Vector3i(
//                 max 0 pos.x,
//                 max 0 pos.y,
//                 max 0 pos.z
//             )
//             seq {
//                 for x in lower.x..upper.x do
//                 for y in lower.y..upper.y do
//                 for z in lower.z..upper.z do
//                     if x <> pos.x && y <> pos.y && z <> pos.z then
//                         Vector3i(x, y, z)
//             }
//         member inline self.GetCellAt(pos: Vector3i) = self.grid[pos.x,pos.y,pos.z]

//         member self.setIntegrationField =

//             let openQueue = new Queue<Vector3i>()

//             openQueue.Enqueue target

//             let mutable current = Vector3i.Zero
//             while openQueue.TryDequeue &current do

//                 let mutable currentCell = self.GetCellAt(current)

                
//                 let walkable = seq {
//                     for elem in self.GetNeighbors current do
//                         if self.IsWalkablePosition elem then elem
//                 }
//                 for neighborPos in walkable do
//                     let mutable neighborCell = self.GetCellAt(neighborPos)

//                     let newCost =uint16 <| (min ((uint currentCell.Cost) + (uint neighborCell.BaseCost)) (uint Cell.maxPassableCost))
                    
//                     if neighborCell.Cost > newCost then do
//                         neighborCell <- neighborCell.AddCellCost(&currentCell)
//                         self.grid[neighborPos.x,neighborPos.y,neighborPos.z] = neighborCell
//                             |> ignore

//                         if not (openQueue.Contains neighborPos) then do
//                             openQueue.Enqueue neighborPos
//             0
        
//         static member Directions = [Vector3i.Left, Vector3i.Right, Vector3i.Down, Vector3i.Up, Vector3i.Forward, Vector3i.Back, // Dir4
//             Vector3i.Up + Vector3i.Right,
//             Vector3i.Up + Vector3i.Left,
//             Vector3i.Up + Vector3i.Forward,
//             Vector3i.Up + Vector3i.Back,
//             Vector3i.Down + Vector3i.Right,
//             Vector3i.Down + Vector3i.Left,
//             Vector3i.Down + Vector3i.Forward,
//             Vector3i.Down + Vector3i.Back, // Dir8 ends here
//             Vector3i.Zero] // Dir9

//         static member inline Directions4 = FlowField.Directions.GetSlice(Some 0, Some 6)
//         static member inline Directions8 = FlowField.Directions.GetSlice(Some 0,Some 14)
        
        

//         new() = FlowField (Vector3i.One*4, Vector3i.One)
//         new(gridSize) = FlowField(gridSize, 
//             Vector3i(
//                 randi gridSize.x, 
//                 randi gridSize.y, 
//                 randi gridSize.z
//             )
//         )


        
    
//     let a = ref Cell.Default

//     type asd = {
//         pos: Vector3i
//         cost: int
//     }



