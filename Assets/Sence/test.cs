// using System.Collections;
// using System.Collections.Generic;
// using UnityEngine;

// public class GridRenderer : MonoBehaviour
// {
//     private const int CELL_SIZE = 1;
//     private const int ROWS = 4;
//     private const int COLUMNS = 4;

//     private Vector3[] vertices;
//     private int[] triangles;

//     private int[][] cells;
//     private bool[][] paintedCells;

//     void Start()
//     {
//         // 创建网格的顶点和三角形索引
//         CreateMesh();
//         // 创建网格格子
//         CreateCells();
//     }

//     void Update()
//     {
//         // 每一帧都重新绘制网格
//         DrawGrid();
//     }

//     private void CreateMesh()
//     {
//         // 计算网格的顶点数量
//         int vertexCount = ROWS * COLUMNS;

//         // 创建网格的顶点数组
//         vertices = new Vector3[vertexCount];

//         // 创建网格的三角形索引数组
//         triangles = new int[(ROWS - 1) * COLUMNS * 6];

//         // 计算网格的顶点坐标
//         for (int i = 0; i < vertexCount; i++)
//         {
//             int row = i / COLUMNS;
//             int col = i % COLUMNS;

//             vertices[i] = new Vector3(
//                 col * CELL_SIZE,
//                 0,
//                 row * CELL_SIZE
//             );
//         }

//         // 计算网格的三角形索引
//         int triangleIndex = 0;
//         for (int i = 0; i < ROWS - 1; i++)
//         {
//             for (int j = 0; j < COLUMNS; j++)
//             {
//                 int baseIndex = i * COLUMNS + j;

//                 triangles[triangleIndex++] = baseIndex;
//                 triangles[triangleIndex++] = baseIndex + 1;
//                 triangles[triangleIndex++] = baseIndex + COLUMNS;

//                 triangles[triangleIndex++] = baseIndex + 1;
//                 triangles[triangleIndex++] = baseIndex + COLUMNS + 1;
//                 triangles[triangleIndex++] = baseIndex + 1;
//             }
//         }
//     }

//     private void CreateCells()
//     {
//         // 创建网格格子的二维数组
//         cells = new int[ROWS][COLUMNS];

//         // 创建已绘制格子的二维数组
//         paintedCells = new bool[ROWS][COLUMNS];
//     }

//     private void DrawGrid()
//     {
//         // 获取网格的网格过滤器
//         MeshFilter meshFilter = GetComponent<MeshFilter>();

//         // 如果网格过滤器不存在，则创建一个新的网格过滤器
//         if (meshFilter == null)
//         {
//             meshFilter = gameObject.AddComponent<MeshFilter>();
//         }

//         // 获取网格的网格渲染器
//         MeshRenderer meshRenderer = GetComponent<MeshRenderer>();

//         // 如果网格渲染器不存在，则创建一个新的网格渲染器
//         if (meshRenderer == null)
//         {
//             meshRenderer = gameObject.AddComponent<MeshRenderer>();
//         }

//         // 设置网格的顶点数组和三角形索引数组
//         meshFilter.mesh.vertices = vertices;
//         meshFilter.mesh.triangles = triangles;

//         // 设置网格的材质
//         meshRenderer.material = new Material(Shader.Find("Standard"));

//         // 设置网格的渲染模式
//         meshRenderer.renderMode = RenderMode.Grid;

//         // 设置网格的大小
//         meshRenderer.bounds.size = new Vector3(
//             CELL_SIZE * COLUMNS,
//             CELL_SIZE,
//             CELL_SIZE * ROWS
//         );

//         // 遍历网格格子
//         for (int i = 0; i < ROWS; i++)
//         {
//             for (int j = 0; j < COLUMNS; j++)
//             {
//                 Vector3 cellPosition = new Vector3(
//                     j * CELL_SIZE,
//                     0,
//                     i * CELL_SIZE
//                 );

//                 GUIStyle style = new GUIStyle();

//                 // 设置格子的背景颜色
//                 style.normal.background = paintedCells[i][j] ? Color.white : new Color(0.5f, 0.5f, 0.5f);

//                 // 设置格子的边框颜色
//                 style.border = new Color(0, 0, 0, 0.5f);

//                 // 设置格子的大小
//                 style.fixedWidth = CELL_SIZE;
//                 style.fixedHeight = CELL_SIZE;

//                 // 在格子上绘制背景和边框
//                 GUI.Box(cellPosition, style);
//             }
//         }
//     }

//     void OnGUI()
//     {
//         // 遍历网格格子
//         for (int i = 0; i < ROWS; i++)
//         {
//             for (int j = 0; j < COLUMNS; j++)
//             {
//                 Vector3 cellPosition = new Vector3(
//                     j * CELL_SIZE,
//                     0,
//                     i * CELL_SIZE
//                 );

//                 // 获取鼠标在屏幕上的坐标
//                 Vector2 mousePosition = GUIUtility.ScreenToWorldPoint(Event.current.mousePosition);

//                 // 如果鼠标在格子内，设置格子为已绘制
//                 if (Vector3.Distance(cellPosition, mousePosition) < CELL_SIZE * 0.5f)
//                 {
//                     paintedCells[i][j] = true;
//                 }

//                 // 如果鼠标左键按下，并且鼠标在格子内，设置格子为未绘制
//                 if (Event.current.type == EventType.MouseDown && Event.current.button == 0 && Vector3.Distance(cellPosition, mousePosition) < CELL_SIZE * 0.5f)
//                 {
//                     paintedCells[i][j] = false;
//                 }
//             }
//         }
//     }
// }