// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Glass"
{
	Properties
	{
		_RefraTex("RefraTex", 2D) = "white" {}
		_RefractIntensity("RefractIntensity", Range( 0 , 1)) = 1
		[HDR]_RefracColor("RefracColor", Color) = (1,1,1,1)
		_MatcapTex("MatcapTex", 2D) = "white" {}

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
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _MatcapTex;
			uniform float4 _RefracColor;
			uniform sampler2D _RefraTex;
			uniform float _RefractIntensity;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord2.xyz = ase_worldNormal;
				
				o.ase_texcoord1 = v.vertex;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.w = 0;
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
				float3 objToWorld7 = mul( unity_ObjectToWorld, float4( i.ase_texcoord1.xyz, 1 ) ).xyz;
				float3 normalizeResult8 = normalize( objToWorld7 );
				float3 ase_worldNormal = i.ase_texcoord2.xyz;
				float3 break13 = cross( normalizeResult8 , mul( UNITY_MATRIX_V, float4( ase_worldNormal , 0.0 ) ).xyz );
				float2 appendResult15 = (float2(-break13.y , break13.x));
				float2 matcap_UV219 = (appendResult15*1.0 + 0.0);
				float4 tex2DNode34 = tex2D( _MatcapTex, matcap_UV219 );
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult20 = dot( ase_worldNormal , ase_worldViewDir );
				float smoothstepResult21 = smoothstep( 0.0 , 1.0 , dotResult20);
				float ThickNess23 = ( 1.0 - smoothstepResult21 );
				float temp_output_27_0 = ( ThickNess23 * _RefractIntensity );
				float4 lerpResult32 = lerp( _RefracColor , tex2D( _RefraTex, ( matcap_UV219 + temp_output_27_0 ) ) , temp_output_27_0);
				float4 appendResult40 = (float4(( tex2DNode34 + lerpResult32 ).rgb , saturate( max( tex2DNode34.r , ThickNess23 ) )));
				
				
				finalColor = appendResult40;
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
Node;AmplifyShaderEditor.CommentaryNode;25;-828.1252,-194.5;Inherit;False;1055.826;391.9135;ThickNess;6;1;20;3;21;22;23;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;24;-832.11,-709.2159;Inherit;False;1700.366;468.7888;MatcapUV2;12;6;7;8;9;10;11;12;13;16;15;17;19;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TransformPositionNode;7;-595.7537,-658.3311;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;8;-374.5228,-640.5956;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewMatrixNode;9;-543.664,-506.4271;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-377.6636,-524.4271;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CrossProductOpNode;12;-176.5325,-573.3372;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;13;12.09766,-567.1682;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.NegateNode;16;137.4704,-457.1085;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;15;266.3677,-574.0348;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;17;436.4042,-561.5988;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;19;644.2563,-532.7194;Inherit;False;matcap_UV2;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;20;-513.6936,-51.74028;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;3;-742.256,9.413476;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SmoothstepOpNode;21;-364.432,-57.69667;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;22;-171.2141,-53.65308;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;3.699519,-58.08704;Inherit;False;ThickNess;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;30;-725.3699,504.2647;Inherit;False;19;matcap_UV2;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;32;130.5723,557.5764;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-704.27,776.9639;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;29;-518.3691,490.7648;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;31;-311.7694,495.7648;Inherit;True;Property;_RefraTex;RefraTex;0;0;Create;True;0;0;0;False;0;False;-1;caa6300437e686744806a7fec3c1f39e;caa6300437e686744806a7fec3c1f39e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;26;-976.5677,726.1709;Inherit;False;23;ThickNess;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;33;-195.514,295.1151;Inherit;False;Property;_RefracColor;RefracColor;2;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;37;716.2181,546.4103;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;38;465.6606,608.3299;Inherit;False;23;ThickNess;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;39;886.1367,565.1302;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;809.817,367.8521;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;40;1070.455,375.0521;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1375.608,398.9689;Float;False;True;-1;2;ASEMaterialInspector;100;5;Glass;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;4;1;False;;1;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-1048.67,809.0643;Inherit;False;Property;_RefractIntensity;RefractIntensity;1;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;1;-778.1252,-144.5;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;6;-782.11,-659.2159;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;11;-615.664,-423.4271;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;34;341.957,313.1356;Inherit;True;Property;_MatcapTex;MatcapTex;3;0;Create;True;0;0;0;False;0;False;-1;None;431c1eb21d389d34a885b2f32aedb1bf;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;35;125.1443,308.8114;Inherit;True;19;matcap_UV2;1;0;OBJECT;;False;1;FLOAT2;0
WireConnection;7;0;6;0
WireConnection;8;0;7;0
WireConnection;10;0;9;0
WireConnection;10;1;11;0
WireConnection;12;0;8;0
WireConnection;12;1;10;0
WireConnection;13;0;12;0
WireConnection;16;0;13;1
WireConnection;15;0;16;0
WireConnection;15;1;13;0
WireConnection;17;0;15;0
WireConnection;19;0;17;0
WireConnection;20;0;1;0
WireConnection;20;1;3;0
WireConnection;21;0;20;0
WireConnection;22;0;21;0
WireConnection;23;0;22;0
WireConnection;32;0;33;0
WireConnection;32;1;31;0
WireConnection;32;2;27;0
WireConnection;27;0;26;0
WireConnection;27;1;28;0
WireConnection;29;0;30;0
WireConnection;29;1;27;0
WireConnection;31;1;29;0
WireConnection;37;0;34;1
WireConnection;37;1;38;0
WireConnection;39;0;37;0
WireConnection;36;0;34;0
WireConnection;36;1;32;0
WireConnection;40;0;36;0
WireConnection;40;3;39;0
WireConnection;0;0;40;0
WireConnection;34;1;35;0
ASEEND*/
//CHKSM=4B764844C87C8641A68E2073609C4D5012857910