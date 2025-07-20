// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "CodeRain"
{
	Properties
	{
		[NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
		[NoScaleOffset]_RainTex("RainTex", 2D) = "white" {}
		[NoScaleOffset]_AddTex("AddTex", 2D) = "white" {}
		[HDR]_MainColor("MainColor", Color) = (0.2196078,2,1.121569,1)
		[HDR]_SmoothColor("SmoothColor", Color) = (1.498039,1.498039,1.498039,1)
		_X("X", Float) = 8
		_Y("Y", Float) = 8
		_pX("pX", Float) = 8
		_Smooth("Smooth", Range( 0 , 1)) = 0.6149289
		_NoiseSpeed("NoiseSpeed", Range( 0 , 10)) = 7
		_LerpIn("LerpIn", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
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

			uniform sampler2D _MainTex;
			uniform float _X;
			uniform float _Y;
			uniform sampler2D _RainTex;
			uniform float _pX;
			uniform float _NoiseSpeed;
			uniform float4 _MainColor;
			uniform float _Smooth;
			uniform float4 _SmoothColor;
			uniform sampler2D _AddTex;
			uniform float _LerpIn;
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

				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
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
				float2 appendResult5 = (float2(_X , _Y));
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles6 = 8.0 * 8.0;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset6 = 1.0f / 8.0;
				float fbrowsoffset6 = 1.0f / 8.0;
				// Speed of animation
				float fbspeed6 = _Time.y * 2.0;
				// UV Tiling (col and row offset)
				float2 fbtiling6 = float2(fbcolsoffset6, fbrowsoffset6);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex6 = round( fmod( fbspeed6 + 0.0, fbtotaltiles6) );
				fbcurrenttileindex6 += ( fbcurrenttileindex6 < 0) ? fbtotaltiles6 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox6 = round ( fmod ( fbcurrenttileindex6, 8.0 ) );
				// Multiply Offset X by coloffset
				float fboffsetx6 = fblinearindextox6 * fbcolsoffset6;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy6 = round( fmod( ( fbcurrenttileindex6 - fblinearindextox6 ) / 8.0, 8.0 ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy6 = (int)(8.0-1) - fblinearindextoy6;
				// Multiply Offset Y by rowoffset
				float fboffsety6 = fblinearindextoy6 * fbrowsoffset6;
				// UV Offset
				float2 fboffset6 = float2(fboffsetx6, fboffsety6);
				// Flipbook UV
				half2 fbuv6 = ( i.ase_texcoord1.xy * appendResult5 ) * fbtiling6 + fboffset6;
				// *** END Flipbook UV Animation vars ***
				float4 UvAnimation14 = tex2D( _MainTex, fbuv6 );
				float2 texCoord15 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float pixelWidth16 =  1.0f / _pX;
				float pixelHeight16 = 1.0f / 1.0;
				half2 pixelateduv16 = half2((int)(texCoord15.x / pixelWidth16) * pixelWidth16, (int)(texCoord15.y / pixelHeight16) * pixelHeight16);
				float simplePerlin2D22 = snoise( pixelateduv16*_NoiseSpeed );
				simplePerlin2D22 = simplePerlin2D22*0.5 + 0.5;
				float2 temp_cast_0 = (simplePerlin2D22).xx;
				float2 panner23 = ( 1.0 * _Time.y * temp_cast_0 + texCoord15);
				float4 tex2DNode25 = tex2D( _RainTex, panner23 );
				float4 FlowRain47 = tex2DNode25;
				float4 temp_cast_1 = ((0.2 + (_Smooth - 0.0) * (0.8 - 0.2) / (1.0 - 0.0))).xxxx;
				float4 temp_cast_2 = (1.0).xxxx;
				float4 smoothstepResult35 = smoothstep( temp_cast_1 , temp_cast_2 , tex2DNode25);
				float4 Top46 = ( smoothstepResult35 * UvAnimation14 * _SmoothColor );
				float4 temp_output_48_0 = ( ( UvAnimation14 * FlowRain47 * _MainColor ) + Top46 );
				float2 uv_AddTex52 = i.ase_texcoord1.xy;
				float4 lerpResult51 = lerp( temp_output_48_0 , ( temp_output_48_0 + tex2D( _AddTex, uv_AddTex52 ) ) , _LerpIn);
				
				
				finalColor = lerpResult51;
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
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2;-109.6,-132.6;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;6;339.6,-130.4;Inherit;True;0;0;6;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;9;90.59985,-39.6;Inherit;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;0;False;0;False;8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;7;76.59992,134.9;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;5;-212.6,-9.599998;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-380.6,-24.6;Inherit;False;Property;_X;X;5;0;Create;True;0;0;0;False;0;False;8;40;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-382.6,52.39999;Inherit;False;Property;_Y;Y;6;0;Create;True;0;0;0;False;0;False;8;40;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-361.4108,469.4319;Inherit;False;Property;_pX;pX;7;0;Create;True;0;0;0;False;0;False;8;40;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCPixelate;16;-129.1109,388.6319;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-105.8981,663.6145;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;9;0;Create;True;0;0;0;False;0;False;7;10;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;23;456.1019,329.6144;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;22;207.1326,385.1269;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;15;-366.1152,331.377;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;38;634.335,650.4837;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.2;False;4;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;599.8831,851.0433;Inherit;False;Constant;_Float2;Float 1;6;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;35;903.7991,612.3402;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;14;986.8638,-113.2649;Inherit;False;UvAnimation;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;36;328.5257,657.082;Inherit;False;Property;_Smooth;Smooth;8;0;Create;True;0;0;0;False;0;False;0.6149289;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;45;888.1682,866.5823;Inherit;False;14;UvAnimation;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;1185.394,609.1398;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;46;1457.117,615.6392;Inherit;False;Top;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;1666.934,-65.18729;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;30;1348.253,-83.64373;Inherit;False;14;UvAnimation;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;1356.69,24.80916;Inherit;False;47;FlowRain;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;48;1951.324,-77.02219;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;1071.028,340.3029;Inherit;False;FlowRain;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;40;897.9041,970.7407;Inherit;False;Property;_SmoothColor;SmoothColor;4;1;[HDR];Create;True;0;0;0;False;0;False;1.498039,1.498039,1.498039,1;2,2,2,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;33;1339.792,123.7594;Inherit;False;Property;_MainColor;MainColor;3;1;[HDR];Create;True;0;0;0;False;0;False;0.2196078,2,1.121569,1;0,2.670157,0.2691933,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;13;659.3185,-137.3911;Inherit;True;Property;_MainTex;MainTex;0;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;13;f3415fa2a0af97846b553af06dd9a778;f3415fa2a0af97846b553af06dd9a778;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;25;718.3818,336.0685;Inherit;True;Property;_RainTex;RainTex;1;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;6874bd2bb88db76488aa009cebc049d3;6874bd2bb88db76488aa009cebc049d3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;49;-423.9988,-148.5791;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;43;1566.825,204.9562;Inherit;False;46;Top;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;53;2141.143,182.051;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;51;2348.143,77.05103;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;54;2051.143,309.051;Inherit;False;Property;_LerpIn;LerpIn;10;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;2592.813,20.73999;Float;False;True;-1;2;ASEMaterialInspector;100;5;CodeRain;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SamplerNode;52;1782.142,221.051;Inherit;True;Property;_AddTex;AddTex;2;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;b3d418be83655c34eb5050ed5456c3ec;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;8;86.39991,41.00001;Inherit;False;Constant;_Speed;Speed;2;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
WireConnection;2;0;49;0
WireConnection;2;1;5;0
WireConnection;6;0;2;0
WireConnection;6;1;9;0
WireConnection;6;2;9;0
WireConnection;6;3;8;0
WireConnection;6;5;7;0
WireConnection;5;0;3;0
WireConnection;5;1;4;0
WireConnection;16;0;15;0
WireConnection;16;1;20;0
WireConnection;23;0;15;0
WireConnection;23;2;22;0
WireConnection;22;0;16;0
WireConnection;22;1;24;0
WireConnection;38;0;36;0
WireConnection;35;0;25;0
WireConnection;35;1;38;0
WireConnection;35;2;37;0
WireConnection;14;0;13;0
WireConnection;44;0;35;0
WireConnection;44;1;45;0
WireConnection;44;2;40;0
WireConnection;46;0;44;0
WireConnection;32;0;30;0
WireConnection;32;1;31;0
WireConnection;32;2;33;0
WireConnection;48;0;32;0
WireConnection;48;1;43;0
WireConnection;47;0;25;0
WireConnection;13;1;6;0
WireConnection;25;1;23;0
WireConnection;53;0;48;0
WireConnection;53;1;52;0
WireConnection;51;0;48;0
WireConnection;51;1;53;0
WireConnection;51;2;54;0
WireConnection;0;0;51;0
ASEEND*/
//CHKSM=BFBCBDE83808850FF35F803E60A6B2399F64056D