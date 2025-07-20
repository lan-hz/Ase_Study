// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Sca"
{
	Properties
	{
		_MainTex("网格贴图", 2D) = "white" {}
		[NoScaleOffset]_Noise("波线贴图", 2D) = "white" {}
		[NoScaleOffset]_EdgeTex("边缘光贴图", 2D) = "white" {}
		[HDR]_UvColor("背景色", Color) = (1,1,1,1)
		[HDR]_MainColor("网格颜色", Color) = (1,1,1,1)
		[HDR]_NoiseColor("波线颜色", Color) = (0,0,0,0)
		_Power("渐变范围", Range( 0 , 1)) = 1
		_NoiseSpeed("波动速度", Float) = 1
		_PaintIntensidy("背景色强度", Range( 0 , 1)) = 0
		_NoiseTilling("波线数量", Range( 0 , 20)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" "Queue"="AlphaTest" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend One One
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite Off
		ZTest NotEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"

			CGPROGRAM

			#define ASE_ABSOLUTE_VERTEX_POS 1


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

			uniform float4 _MainColor;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float _Power;
			uniform float4 _UvColor;
			uniform sampler2D _EdgeTex;
			uniform float _PaintIntensidy;
			uniform sampler2D _Noise;
			uniform float _NoiseSpeed;
			uniform float _NoiseTilling;
			uniform float4 _NoiseColor;

			
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
				float2 uv_MainTex = i.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 texCoord22 = i.ase_texcoord1;
				texCoord22.xy = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float Alpha44 = saturate( pow( texCoord22.y , ( 1.0 - (-2.0 + (_Power - 0.0) * (1.0 - -2.0) / (1.0 - 0.0)) ) ) );
				float4 MainTex45 = ( _MainColor * tex2D( _MainTex, uv_MainTex ) * Alpha44 );
				float2 uv_EdgeTex61 = i.ase_texcoord1.xy;
				float4 Back50 = ( _UvColor * ( tex2D( _EdgeTex, uv_EdgeTex61 ) + (0.0 + (_PaintIntensidy - 0.0) * (0.5 - 0.0) / (1.0 - 0.0)) ) * Alpha44 );
				float2 temp_cast_0 = (_NoiseSpeed).xx;
				float2 texCoord15 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner13 = ( _Time.y * temp_cast_0 + ( texCoord15 * _NoiseTilling ));
				float4 Noise48 = ( tex2D( _Noise, panner13 ) * _NoiseColor * Alpha44 );
				float4 appendResult31 = (float4(( MainTex45 * Back50 * Noise48 ).rgb , Alpha44));
				
				
				finalColor = appendResult31;
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
Node;AmplifyShaderEditor.CommentaryNode;63;-674.6545,-757.6898;Inherit;False;1075.249;576.1306;Comment;6;3;53;1;4;2;45;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;62;-736.5678,-136.0999;Inherit;False;1206.01;539.2045;Comment;7;70;68;61;8;6;54;66;Back;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;59;-736.5911,547.9006;Inherit;False;1611.791;582.5372;Comment;11;13;20;18;74;76;21;80;55;34;15;87;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;58;-782.0643,1173.102;Inherit;False;1038.867;390.5434;Comment;7;44;27;41;81;26;25;22;Alpha;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;56;555.8006,-351.0868;Inherit;False;50;Back;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;459.7622,649.462;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;53;-177.2545,-297.5594;Inherit;False;44;Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;1.901411,-523.3875;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;45;176.5946,-498.9892;Inherit;False;MainTex;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;218.5152,824.678;Inherit;False;44;Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;3;-331.6645,-707.6898;Inherit;False;Property;_MainColor;网格颜色;4;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;21;129.4838,626.7349;Inherit;True;Property;_Noise;波线贴图;1;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;9d9fc823d25de2542b7e6daa2f8a6721;b0ac123a71df32b45a82f12e66c58799;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;66;-104.163,86.29352;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;54;-16.81839,209.8365;Inherit;False;44;Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;138.1613,-87.90285;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;8;-667.4743,-79.313;Inherit;False;Property;_UvColor;背景色;3;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;0,0.7294118,0.7490196,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;61;-425.9278,-10.90987;Inherit;True;Property;_EdgeTex;边缘光贴图;2;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;50;349.3329,-67.82127;Inherit;False;Back;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;22;-732.0645,1229.891;Inherit;False;0;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1682.57,-430.1835;Float;False;True;-1;2;ASEMaterialInspector;100;5;Sca;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;4;1;False;;1;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;6;False;;True;True;0;False;;0;False;;True;2;RenderType=Opaque=RenderType;Queue=AlphaTest=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;0;638463462673822190;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SamplerNode;1;-364.3975,-531.3837;Inherit;True;Property;_MainTex;网格贴图;0;0;Create;False;0;0;0;False;0;False;-1;8658aef8910eaef47b6d78fc2704ea08;8658aef8910eaef47b6d78fc2704ea08;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-624.6545,-517.6206;Inherit;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;68;-637.3979,183.6268;Inherit;False;Property;_PaintIntensidy;背景色强度;8;0;Create;False;0;0;0;False;0;False;0;0.69;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;70;-277.6112,176.8055;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;13;-92.39877,849.3516;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;1,1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;20;-337.9452,1003.436;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-336.1473,925.8347;Inherit;False;Property;_NoiseSpeed;波动速度;7;0;Create;False;0;0;0;False;0;False;1;2.37;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-589.7847,814.4404;Inherit;False;Property;_NoiseTilling;波线数量;9;0;Create;False;0;0;0;False;0;False;1;10;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-201.5512,726.6265;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;15;-686.7515,604.6976;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;25;-334.5608,1243.492;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-774.4477,1402.272;Inherit;False;Property;_Power;渐变范围;6;0;Create;False;0;0;0;False;0;False;1;0.75;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;81;-487.0125,1391.325;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-2;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;41;-297.6309,1405.137;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;27;-147.9642,1243.213;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;44;56.60426,1245.195;Inherit;False;Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;673.9885,-106.5298;Inherit;False;44;Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;48;968.9918,675.6463;Inherit;True;Noise;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;80;315.2104,922.4058;Inherit;False;Property;_NoiseColor;波线颜色;5;1;[HDR];Create;False;0;0;0;False;0;False;0,0,0,0;0,5.216475,4.997984,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;87;595.7501,916.4154;Inherit;False;Constant;_Float0;Float 0;10;0;Create;True;0;0;0;False;0;False;44.45;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;57;512.0734,-223.371;Inherit;False;48;Noise;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;437.3878,-473.6958;Inherit;False;45;MainTex;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;31;1166.54,-347.0196;Inherit;True;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;860.3962,-385.4825;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
WireConnection;34;0;21;0
WireConnection;34;1;80;0
WireConnection;34;2;55;0
WireConnection;4;0;3;0
WireConnection;4;1;1;0
WireConnection;4;2;53;0
WireConnection;45;0;4;0
WireConnection;21;1;13;0
WireConnection;66;0;61;0
WireConnection;66;1;70;0
WireConnection;6;0;8;0
WireConnection;6;1;66;0
WireConnection;6;2;54;0
WireConnection;50;0;6;0
WireConnection;0;0;31;0
WireConnection;1;1;2;0
WireConnection;70;0;68;0
WireConnection;13;0;74;0
WireConnection;13;2;18;0
WireConnection;13;1;20;0
WireConnection;74;0;15;0
WireConnection;74;1;76;0
WireConnection;25;0;22;2
WireConnection;25;1;41;0
WireConnection;81;0;26;0
WireConnection;41;0;81;0
WireConnection;27;0;25;0
WireConnection;44;0;27;0
WireConnection;48;0;34;0
WireConnection;31;0;88;0
WireConnection;31;3;51;0
WireConnection;88;0;52;0
WireConnection;88;1;56;0
WireConnection;88;2;57;0
ASEEND*/
//CHKSM=AE0886BB226BD6DE73812211E45C3F8A258888BF