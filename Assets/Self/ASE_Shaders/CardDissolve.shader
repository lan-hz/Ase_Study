// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "CardDissolve"
{
	Properties
	{
		[NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
		[NoScaleOffset]_DissolveTex("DissolveTex", 2D) = "white" {}
		[NoScaleOffset]_LightBeam("LightBeam", 2D) = "white" {}
		[NoScaleOffset]_Tex("Tex", 2D) = "white" {}
		_Edge("Edge", 2D) = "white" {}
		_NoiseTex("NoiseTex", 2D) = "white" {}
		_DissovleIns("DissovleIns", Range( 0 , 1)) = 1
		_s_x("s_x", Float) = 0
		_s_y("s_y", Float) = 1
		_NoiseIns("NoiseIns", Range( 0 , 1)) = 0.3
		[HDR]_LightColor("LightColor", Color) = (1,1,1,0)
		[HDR]_NoiseColor("NoiseColor", Color) = (1,1,1,0)
		_EdgeIns("EdgeIns", Float) = 1
		[HDR]_EdgeColor("EdgeColor", Color) = (1,1,1,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha
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
			uniform sampler2D _DissolveTex;
			uniform float4 _DissolveTex_ST;
			uniform float _DissovleIns;
			uniform sampler2D _NoiseTex;
			uniform float _s_x;
			uniform float _s_y;
			uniform float4 _NoiseTex_ST;
			uniform float _NoiseIns;
			uniform float4 _NoiseColor;
			uniform sampler2D _LightBeam;
			uniform float4 _LightBeam_ST;
			uniform sampler2D _Tex;
			uniform float4 _LightColor;
			uniform sampler2D _Edge;
			uniform float4 _EdgeColor;
			uniform float _EdgeIns;

			
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
				float2 uv_DissolveTex = i.ase_texcoord1.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				float DissovleIne50 = _DissovleIns;
				float DissOlve51 = step( ( 1.0 - tex2D( _DissolveTex, uv_DissolveTex ).r ) , (-0.1 + (DissovleIne50 - 0.0) * (1.05 - -0.1) / (1.0 - 0.0)) );
				float4 Mian59 = ( tex2D( _MainTex, i.ase_texcoord1.xy ) * DissOlve51 );
				float2 appendResult31 = (float2(_s_x , _s_y));
				float2 uv_NoiseTex = i.ase_texcoord1.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 panner28 = ( 1.0 * _Time.y * appendResult31 + uv_NoiseTex);
				float4 Noise58 = ( DissOlve51 * ( 0.0 + tex2D( _NoiseTex, panner28 ).r ) * _NoiseIns * _NoiseColor );
				float2 uv_LightBeam = i.ase_texcoord1.xy * _LightBeam_ST.xy + _LightBeam_ST.zw;
				float2 appendResult21 = (float2(0.0 , (-1.0 + (DissovleIne50 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0))));
				float2 uv_Tex33 = i.ase_texcoord1.xy;
				float4 LightBeam60 = ( tex2D( _LightBeam, ( uv_LightBeam + appendResult21 ) ) * tex2D( _Tex, uv_Tex33 ) * _LightColor );
				float2 appendResult45 = (float2(0.0 , (-1.0 + (DissovleIne50 - 0.0) * (0.5 - -1.0) / (1.0 - 0.0))));
				float4 Edge61 = ( DissOlve51 * tex2D( _Edge, ( uv_LightBeam + appendResult45 ) ).r * _EdgeColor * _EdgeIns );
				
				
				finalColor = ( Mian59 + Noise58 + LightBeam60 + Edge61 );
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
Node;AmplifyShaderEditor.CommentaryNode;67;-1525.741,-1299.572;Inherit;False;565.0596;170.1671;Comment;2;9;50;InParameter;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;66;-1609.724,1369.041;Inherit;False;2156.182;511.9216;Comment;12;41;42;43;45;47;46;49;44;48;55;57;61;Edge;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;65;-1601.695,770.8291;Inherit;False;1536.267;510.99;Comment;12;29;30;38;58;54;32;40;39;25;28;27;31;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;64;-1572.979,11.9203;Inherit;False;1786.974;670.0017;Comment;11;17;18;19;22;56;21;16;33;35;37;60;LightBeam;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;63;-1570.965,-493.7511;Inherit;False;1633.308;406.313;Comment;7;6;5;3;11;51;12;52;Dissolve;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;62;-1569.426,-989.0088;Inherit;False;1304.063;384.5745;Comment;5;1;15;59;53;2;MainTex;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;1;-1252.95,-932.3367;Inherit;True;Property;_MainTex;MainTex;0;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;b284b38597fdea541ac991e0aa0ef66d;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-805.279,-939.0088;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;59;-490.1633,-934.949;Inherit;False;Mian;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;53;-1019.319,-719.8343;Inherit;False;51;DissOlve;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;2;-1519.426,-909.908;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;6;-979.9662,-435.1649;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-1520.965,-421.1649;Inherit;False;0;3;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-1293.966,-442.1649;Inherit;True;Property;_DissolveTex;DissolveTex;1;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;d4e7b5056cb05f444ba54d254c4762da;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;11;-451.7685,-443.7512;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;12;-639.2418,-319.6215;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.1;False;4;FLOAT;1.05;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;-961.1265,-202.8385;Inherit;False;50;DissovleIne;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;17;-1177.542,67.34682;Inherit;False;0;16;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;18;-839.5744,87.14489;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-1152.692,199.1811;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;22;-1317.632,226.6452;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;56;-1522.979,228.0621;Inherit;False;50;DissovleIne;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;21;-1020.455,203.8865;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;16;-686.8199,61.92031;Inherit;True;Property;_LightBeam;LightBeam;2;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;9141fe797bacf4646b1d8e6c04826407;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;33;-679.1854,272.9027;Inherit;True;Property;_Tex;Tex;3;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;0e572ede670fd4f4a979100a27fd73fa;0e572ede670fd4f4a979100a27fd73fa;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-296.204,77.00609;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;37;-618.1769,472.9221;Inherit;False;Property;_LightColor;LightColor;10;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;60;-10.80403,79.45934;Inherit;False;LightBeam;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-1551.695,981.0014;Inherit;False;Property;_s_x;s_x;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-1545.295,1073.802;Inherit;False;Property;_s_y;s_y;8;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-503.2482,880.9897;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;58;-290.2283,876.9808;Inherit;False;Noise;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;54;-675.7012,820.8292;Inherit;False;51;DissOlve;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;-699.3526,898.4404;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;40;-733.3347,1072.82;Inherit;False;Property;_NoiseColor;NoiseColor;11;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;39;-1049.704,1038.94;Inherit;False;Property;_NoiseIns;NoiseIns;9;0;Create;True;0;0;0;False;0;False;0.3;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;25;-1069.295,841.4013;Inherit;True;Property;_NoiseTex;NoiseTex;5;0;Create;True;0;0;0;False;0;False;-1;1882f3078d58f5a4c95d66011316fe6f;d4e7b5056cb05f444ba54d254c4762da;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;28;-1247.295,866.0012;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;27;-1512.495,863.8013;Inherit;False;0;25;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;31;-1395.895,980.2015;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;41;-471.466,1454.665;Inherit;True;Property;_Edge;Edge;4;0;Create;True;0;0;0;False;0;False;-1;7667172725248394185b05e1841e76aa;7667172725248394185b05e1841e76aa;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;42;-723.8217,1448.941;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;43;-1025.422,1419.041;Inherit;False;0;16;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;45;-831.722,1560.741;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;60.26124,1468.667;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;46;-1340.623,1577.841;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-112.3389,1765.563;Inherit;False;Property;_EdgeIns;EdgeIns;12;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-1024.123,1537.341;Inherit;False;Constant;_Float1;Float 0;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;48;-219.2236,1612.869;Inherit;False;Property;_EdgeColor;EdgeColor;13;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;55;-108.6006,1442.384;Inherit;False;51;DissOlve;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;57;-1559.724,1571.987;Inherit;False;50;DissovleIne;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;61;321.6572,1515.575;Inherit;False;Edge;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-1475.741,-1244.805;Inherit;False;Property;_DissovleIns;DissovleIns;6;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;50;-1185.482,-1249.572;Inherit;False;DissovleIne;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;968.8271,-224.335;Float;False;True;-1;2;ASEMaterialInspector;100;5;CardDissolve;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;2;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;3;False;;True;False;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;668.0184,-223.0621;Inherit;True;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;377.1368,-218.8786;Inherit;False;59;Mian;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;69;384.8991,-123.791;Inherit;False;58;Noise;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;71;382.9586,-36.46564;Inherit;False;60;LightBeam;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;72;385.5646,49.80025;Inherit;False;61;Edge;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;51;-162.4574,-431.5602;Inherit;False;DissOlve;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;1;1;2;0
WireConnection;15;0;1;0
WireConnection;15;1;53;0
WireConnection;59;0;15;0
WireConnection;6;0;3;1
WireConnection;3;1;5;0
WireConnection;11;0;6;0
WireConnection;11;1;12;0
WireConnection;12;0;52;0
WireConnection;18;0;17;0
WireConnection;18;1;21;0
WireConnection;22;0;56;0
WireConnection;21;0;19;0
WireConnection;21;1;22;0
WireConnection;16;1;18;0
WireConnection;35;0;16;0
WireConnection;35;1;33;0
WireConnection;35;2;37;0
WireConnection;60;0;35;0
WireConnection;38;0;54;0
WireConnection;38;1;32;0
WireConnection;38;2;39;0
WireConnection;38;3;40;0
WireConnection;58;0;38;0
WireConnection;32;1;25;1
WireConnection;25;1;28;0
WireConnection;28;0;27;0
WireConnection;28;2;31;0
WireConnection;31;0;29;0
WireConnection;31;1;30;0
WireConnection;41;1;42;0
WireConnection;42;0;43;0
WireConnection;42;1;45;0
WireConnection;45;0;44;0
WireConnection;45;1;46;0
WireConnection;47;0;55;0
WireConnection;47;1;41;1
WireConnection;47;2;48;0
WireConnection;47;3;49;0
WireConnection;46;0;57;0
WireConnection;61;0;47;0
WireConnection;50;0;9;0
WireConnection;0;0;36;0
WireConnection;36;0;68;0
WireConnection;36;1;69;0
WireConnection;36;2;71;0
WireConnection;36;3;72;0
WireConnection;51;0;11;0
ASEEND*/
//CHKSM=F0BCE84E64B3456489C8C987301F9664F9F17EA1