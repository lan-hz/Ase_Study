// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Electric"
{
	Properties
	{
		_MainTex("主贴图", 2D) = "white" {}
		[NoScaleOffset]_RainTex("扰动贴图", 2D) = "white" {}
		[HDR]_SmoothColor("SmoothColor", Color) = (1.042758,2.316086,0.2053886,1)
		[HDR]_UvColor1("背景色", Color) = (0.2837404,0.8490566,0.251513,1)
		ListNumber("竖列格数", Range( 0 , 20)) = 20
		_Smooth("Smooth", Range( 0 , 1)) = 1
		_NoiseSpeed("NoiseSpeed", Range( 0 , 10)) = 8
		_Power("渐变范围", Range( 0 , 1)) = 0

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend One One
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"

			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float _Smooth;
			uniform sampler2D _RainTex;
			uniform half ListNumber;
			uniform float _NoiseSpeed;
			uniform sampler2D _MainTex;
			uniform float4 _SmoothColor;
			uniform float _Power;
			uniform float4 _UvColor1;
			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord1 = v.ase_texcoord;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float4 temp_cast_0 = ((0.2 + (_Smooth - 0.0) * (0.8 - 0.2) / (1.0 - 0.0))).xxxx;
				float4 temp_cast_1 = (1.0).xxxx;
				float2 texCoord21 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float pixelWidth17 =  1.0f / ListNumber;
				float pixelHeight17 = 1.0f / 1.0;
				half2 pixelateduv17 = half2((int)(texCoord21.x / pixelWidth17) * pixelWidth17, (int)(texCoord21.y / pixelHeight17) * pixelHeight17);
				float simplePerlin2D20 = snoise( pixelateduv17*_NoiseSpeed );
				simplePerlin2D20 = simplePerlin2D20*0.5 + 0.5;
				float2 temp_cast_2 = (simplePerlin2D20).xx;
				clip( 0.999 - texCoord21.y);
				float2 panner19 = ( -1.0 * _Time.y * temp_cast_2 + texCoord21);
				float4 tex2DNode38 = tex2D( _RainTex, panner19 );
				float4 smoothstepResult24 = smoothstep( temp_cast_0 , temp_cast_1 , tex2DNode38);
				float2 texCoord48 = i.ase_texcoord1.xy * float2( 10,10 ) + float2( 0,0 );
				float4 UvAnimation25 = tex2D( _MainTex, texCoord48 );
				float4 Top29 = ( smoothstepResult24 * UvAnimation25 * _SmoothColor );
				float4 texCoord63 = i.ase_texcoord1;
				texCoord63.xy = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float4 Alpha71 = ( saturate( pow( ( 1.0 - texCoord63.y ) , ( 1.0 - (-2.0 + (_Power - 0.0) * (2.0 - -2.0) / (1.0 - 0.0)) ) ) ) * _UvColor1 );
				
				
				finalColor = ( Top29 + Alpha71 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;81;-764.8859,-443.1825;Inherit;False;734.752;366.8392;Comment;4;72;0;49;73;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;79;-1595.714,-352.8719;Inherit;False;765.5829;280.0114;Comment;3;48;37;25;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;78;-1707.56,-26.85684;Inherit;False;2208.033;917.727;Comment;17;21;29;34;27;38;16;17;22;76;24;35;19;28;26;20;18;91;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;62;-1576.33,955.7291;Inherit;False;1459.816;602.0818;Comment;11;75;74;71;70;69;68;67;66;65;64;63;Alpha;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;63;-1526.33,1012.517;Inherit;False;0;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;64;-1114.204,1005.729;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;65;-1306.888,1007.564;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.PowerNode;66;-869.1159,1011.192;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;67;-784.4234,1193.734;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;68;-642.2197,1007.928;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-1407.513,1256.543;Inherit;False;Property;_Power;渐变范围;7;0;Create;False;0;0;0;False;0;False;0;0.21;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;70;-973.9862,1184.491;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-2;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-852.9191,350.6093;Inherit;False;Property;_Smooth;Smooth;5;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;3.94931,302.6676;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;35;-283.5407,664.2691;Inherit;False;Property;_SmoothColor;SmoothColor;2;1;[HDR];Create;True;0;0;0;False;0;False;1.042758,2.316086,0.2053886,1;0,38.93715,9.377532,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;24;-277.6458,305.8676;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-527.9214,518.2424;Inherit;False;Constant;_Float0;Float 0;9;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;72;-508.1367,-329.7436;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-472.8116,1242.969;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;75;-844.4252,1349.793;Inherit;False;Property;_UvColor1;背景色;3;1;[HDR];Create;False;0;0;0;False;0;False;0.2837404,0.8490566,0.251513,1;0,0.343848,0.1552862,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;38;-463.063,29.59727;Inherit;True;Property;_RainTex;扰动贴图;1;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;6874bd2bb88db76488aa009cebc049d3;482ce6055bd4dbb4ab6be41eec2d2250;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;73;-732.0057,-207.9146;Inherit;False;71;Alpha;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;71;-333.4792,1002.192;Inherit;False;Alpha;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;27;-293.2766,560.1103;Inherit;False;25;UvAnimation;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;34;-110.4167,33.83118;Inherit;True;FlowRain;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;29;238.9921,300.4279;Inherit;True;Top;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;49;-748.5362,-340.0818;Inherit;False;29;Top;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-938.8642,-291.4143;Inherit;False;UvAnimation;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;-138.9348,-434.7826;Float;False;True;-1;2;ASEMaterialInspector;100;5;Electric;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;4;1;False;;1;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1287.343,428.6422;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;6;0;Create;True;0;0;0;False;0;False;8;10;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClipNode;91;-1315.891,-34.66595;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT;0.999;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1600.112,241.7933;Half;False;Property;ListNumber;竖列格数;4;0;Create;False;0;0;0;False;0;False;20;20;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCPixelate;17;-1270.955,170.8602;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;22;-547.11,345.4523;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.2;False;4;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;20;-974.3121,78.65504;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;19;-725.343,23.14316;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;-1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;21;-1635.56,26.79234;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;37;-1230.235,-308.2422;Inherit;True;Property;_MainTex;主贴图;0;0;Create;False;0;0;0;False;0;False;-1;f3415fa2a0af97846b553af06dd9a778;2257b8171933fa54ca994908fa870eac;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;48;-1525.243,-299.0618;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;10,10;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;64;0;65;1
WireConnection;65;0;63;0
WireConnection;66;0;64;0
WireConnection;66;1;67;0
WireConnection;67;0;70;0
WireConnection;68;0;66;0
WireConnection;70;0;69;0
WireConnection;28;0;24;0
WireConnection;28;1;27;0
WireConnection;28;2;35;0
WireConnection;24;0;38;0
WireConnection;24;1;22;0
WireConnection;24;2;76;0
WireConnection;72;0;49;0
WireConnection;72;1;73;0
WireConnection;74;0;68;0
WireConnection;74;1;75;0
WireConnection;38;1;19;0
WireConnection;71;0;74;0
WireConnection;34;0;38;0
WireConnection;29;0;28;0
WireConnection;25;0;37;0
WireConnection;0;0;72;0
WireConnection;91;0;21;0
WireConnection;91;2;21;2
WireConnection;17;0;21;0
WireConnection;17;1;16;0
WireConnection;22;0;26;0
WireConnection;20;0;17;0
WireConnection;20;1;18;0
WireConnection;19;0;91;0
WireConnection;19;2;20;0
WireConnection;37;1;48;0
ASEEND*/
//CHKSM=1EA1886DB6B7A8B2B639C19179FFEFB12F3B5929