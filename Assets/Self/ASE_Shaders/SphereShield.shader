// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SphereShield"
{
	Properties
	{
		_Polygon("Polygon", Float) = 3
		_NoiseTex("NoiseTex", 2D) = "white" {}
		_Width("Width", Range( 0 , 1)) = 0.1
		_NoiseIns("NoiseIns", Range( 0 , 10)) = 1
		[HDR]_FrontColor("FrontColor ", Color) = (1,1,1,0)
		[HDR]_BackColor("BackColor", Color) = (1,1,1,0)
		_Min("Min", Range( 0 , 1)) = 0
		_Max("Max", Range( 0 , 10)) = 1

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
		Cull Off
		ColorMask RGBA
		ZWrite Off
		ZTest LEqual
		
		
		
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
				float4 ase_texcoord2 : TEXCOORD2;
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

			uniform float4 _FrontColor;
			uniform float _Min;
			uniform float _Max;
			uniform sampler2D _NoiseTex;
			uniform float4 _NoiseTex_ST;
			uniform float _NoiseIns;
			uniform float _Polygon;
			uniform float _Width;
			uniform float4 _BackColor;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_texcoord1.zw = v.ase_texcoord2.xy;
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
			
			fixed4 frag (v2f i , bool ase_vface : SV_IsFrontFace) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float2 texCoord22 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0.115 );
				float2 appendResult29 = (float2(1.2 , 0.95));
				float2 appendResult39 = (float2(0.2 , -0.2));
				float2 uv3_NoiseTex = i.ase_texcoord1.zw * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 panner36 = ( 1.0 * _Time.y * appendResult39 + uv3_NoiseTex);
				float smoothstepResult52 = smoothstep( _Min , _Max , pow( tex2D( _NoiseTex, panner36 ).r , _NoiseIns ));
				float Noise42 = smoothstepResult52;
				float2 temp_output_44_0 = ( appendResult29 * Noise42 );
				float2 break45 = temp_output_44_0;
				float temp_output_2_0_g3 = _Polygon;
				float cosSides12_g3 = cos( ( UNITY_PI / temp_output_2_0_g3 ) );
				float2 appendResult18_g3 = (float2(( break45.x * cosSides12_g3 ) , ( break45.y * cosSides12_g3 )));
				float2 break23_g3 = ( (texCoord22*2.0 + -1.0) / appendResult18_g3 );
				float polarCoords30_g3 = atan2( break23_g3.x , -break23_g3.y );
				float temp_output_52_0_g3 = ( 6.28318548202515 / temp_output_2_0_g3 );
				float2 appendResult25_g3 = (float2(break23_g3.x , -break23_g3.y));
				float2 finalUVs29_g3 = appendResult25_g3;
				float temp_output_44_0_g3 = ( cos( ( ( floor( ( 0.5 + ( polarCoords30_g3 / temp_output_52_0_g3 ) ) ) * temp_output_52_0_g3 ) - polarCoords30_g3 ) ) * length( finalUVs29_g3 ) );
				float2 temp_cast_0 = (_Width).xx;
				float2 break32 = ( temp_output_44_0 - temp_cast_0 );
				float temp_output_2_0_g2 = _Polygon;
				float cosSides12_g2 = cos( ( UNITY_PI / temp_output_2_0_g2 ) );
				float2 appendResult18_g2 = (float2(( break32.x * cosSides12_g2 ) , ( break32.y * cosSides12_g2 )));
				float2 break23_g2 = ( (texCoord22*2.0 + -1.0) / appendResult18_g2 );
				float polarCoords30_g2 = atan2( break23_g2.x , -break23_g2.y );
				float temp_output_52_0_g2 = ( 6.28318548202515 / temp_output_2_0_g2 );
				float2 appendResult25_g2 = (float2(break23_g2.x , -break23_g2.y));
				float2 finalUVs29_g2 = appendResult25_g2;
				float temp_output_44_0_g2 = ( cos( ( ( floor( ( 0.5 + ( polarCoords30_g2 / temp_output_52_0_g2 ) ) ) * temp_output_52_0_g2 ) - polarCoords30_g2 ) ) * length( finalUVs29_g2 ) );
				float temp_output_46_0 = saturate( ( saturate( ( ( 1.0 - temp_output_44_0_g3 ) / fwidth( temp_output_44_0_g3 ) ) ) - saturate( ( ( 1.0 - temp_output_44_0_g2 ) / fwidth( temp_output_44_0_g2 ) ) ) ) );
				float4 switchResult47 = (((ase_vface>0)?(( _FrontColor * temp_output_46_0 )):(( temp_output_46_0 * _BackColor ))));
				
				
				finalColor = switchResult47;
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
Node;AmplifyShaderEditor.SimpleSubtractOpNode;19;94.70605,-333.8861;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;32;-242.3348,145.882;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleSubtractOpNode;30;-428.6389,104.8442;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-665.6857,-756.9966;Inherit;False;Constant;_y;y;3;0;Create;True;0;0;0;False;0;False;-0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-667.7584,-881.3669;Inherit;False;Constant;_x;x;3;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;36;-338.1775,-1047.194;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;39;-487.4219,-866.8571;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;34;-713.3612,-1047.194;Inherit;False;2;35;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;35;-137.0956,-1056.407;Inherit;True;Property;_NoiseTex;NoiseTex;1;0;Create;True;0;0;0;False;0;False;-1;None;fa99af98603e9404c802419010acbbfd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;40;390.7575,-1055.773;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;43;-1123.919,203.0781;Inherit;False;42;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;29;-870.7905,-78.00153;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;45;-664.7739,-108.7201;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;20;-1077.933,-179.4184;Inherit;False;Constant;_Float6;Float 6;2;0;Create;True;0;0;0;False;0;False;1.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-1074.938,-83.43433;Inherit;False;Constant;_Float7;Float 6;2;0;Create;True;0;0;0;False;0;False;0.95;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;24;-91.54247,-57.80833;Inherit;True;Polygon;-1;;2;6906ef7087298c94c853d6753e182169;0;4;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1;-312.3234,-273.7614;Inherit;True;Polygon;-1;;3;6906ef7087298c94c853d6753e182169;0;4;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;22;-666.9332,-365.6183;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0.115;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;41;86.81331,-868.5641;Inherit;False;Property;_NoiseIns;NoiseIns;3;0;Create;True;0;0;0;False;0;False;1;9;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;46;338.4556,-330.4025;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;49;464.5645,-33.88782;Inherit;False;Property;_BackColor;BackColor;5;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0.6509805,0.96698,2,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-832.7773,79.30242;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-532.7173,262.6755;Inherit;False;Property;_Width;Width;2;0;Create;True;0;0;0;False;0;False;0.1;0.213;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-1078.675,-279.4025;Inherit;False;Property;_Polygon;Polygon;0;0;Create;True;0;0;0;False;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;48;500.7256,-618.604;Inherit;False;Property;_FrontColor;FrontColor ;4;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0,1.443137,1.498039,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;546.1507,-426.0382;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;993.278,-362.6992;Float;False;True;-1;2;ASEMaterialInspector;100;5;SphereShield;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;4;1;False;;1;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;2;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;3;False;;True;False;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;458.6568,-170.7285;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwitchByFaceNode;47;721.0179,-243.6146;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;42;1075.867,-1079.397;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;52;866.172,-1069.605;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;600.3262,-1013.246;Inherit;False;Property;_Min;Min;6;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;604.2263,-829.9461;Inherit;False;Property;_Max;Max;7;0;Create;True;0;0;0;False;0;False;1;0.94;0;10;0;1;FLOAT;0
WireConnection;19;0;1;0
WireConnection;19;1;24;0
WireConnection;32;0;30;0
WireConnection;30;0;44;0
WireConnection;30;1;31;0
WireConnection;36;0;34;0
WireConnection;36;2;39;0
WireConnection;39;0;37;0
WireConnection;39;1;38;0
WireConnection;35;1;36;0
WireConnection;40;0;35;1
WireConnection;40;1;41;0
WireConnection;29;0;20;0
WireConnection;29;1;23;0
WireConnection;45;0;44;0
WireConnection;24;1;22;0
WireConnection;24;2;2;0
WireConnection;24;3;32;0
WireConnection;24;4;32;1
WireConnection;1;1;22;0
WireConnection;1;2;2;0
WireConnection;1;3;45;0
WireConnection;1;4;45;1
WireConnection;46;0;19;0
WireConnection;44;0;29;0
WireConnection;44;1;43;0
WireConnection;50;0;48;0
WireConnection;50;1;46;0
WireConnection;0;0;47;0
WireConnection;51;0;46;0
WireConnection;51;1;49;0
WireConnection;47;0;50;0
WireConnection;47;1;51;0
WireConnection;42;0;52;0
WireConnection;52;0;40;0
WireConnection;52;1;53;0
WireConnection;52;2;54;0
ASEEND*/
//CHKSM=DC28BAFBA671D658CD30481414490EEC5A1AEF73