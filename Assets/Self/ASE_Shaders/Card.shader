// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Card"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_NormalTex("NormalTex", 2D) = "bump" {}
		_NormalScale("NormalScale", Range( 0 , 2)) = 1
		_RotateAngle("RotateAngle", Range( 0 , 360)) = 0
		_RumpFrontIn("RumpFrontIn", Float) = 3
		_RumpBackIn("RumpBackIn", Float) = 3
		_RumpTex("RumpTex", 2D) = "white" {}
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
		Cull Off
		ColorMask RGBA
		ZWrite On
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
			#include "UnityStandardBRDF.cginc"
			#include "UnityStandardUtils.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
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
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _RumpTex;
			uniform float _RotateAngle;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform sampler2D _NormalTex;
			uniform float4 _NormalTex_ST;
			uniform float _NormalScale;
			uniform float _RumpFrontIn;
			uniform float _RumpBackIn;
			inline float3 ASESafeNormalize(float3 inVec)
			{
				float dp3 = max( 0.001f , dot( inVec , inVec ) );
				return inVec* rsqrt( dp3);
			}
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldTangent = UnityObjectToWorldDir(v.ase_tangent);
				o.ase_texcoord2.xyz = ase_worldTangent;
				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord4.xyz = ase_worldBitangent;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
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
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = Unity_SafeNormalize( ase_worldViewDir );
				float3 worldToObjDir29 = ASESafeNormalize( mul( unity_WorldToObject, float4( ase_worldViewDir, 0 ) ).xyz );
				float cos35 = cos( ( ( _RotateAngle / 180.0 ) * UNITY_PI ) );
				float sin35 = sin( ( ( _RotateAngle / 180.0 ) * UNITY_PI ) );
				float2 rotator35 = mul( worldToObjDir29.xy - float2( 0,0 ) , float2x2( cos35 , -sin35 , sin35 , cos35 )) + float2( 0,0 );
				float ViewDir42 = abs( (frac( rotator35.x )*2.0 + -1.0) );
				float saferPower47 = abs( ViewDir42 );
				float2 uv_MainTex = i.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode4 = tex2D( _MainTex, uv_MainTex );
				float2 texCoord7 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_8_0 = step( texCoord7.x , 0.5 );
				float BackMask1 = ( tex2DNode4.a * temp_output_8_0 );
				float3 temp_cast_1 = (ViewDir42).xxx;
				float2 uv_NormalTex = i.ase_texcoord1.xy * _NormalTex_ST.xy + _NormalTex_ST.zw;
				float3 ase_worldTangent = i.ase_texcoord2.xyz;
				float3 ase_worldNormal = i.ase_texcoord3.xyz;
				float3 ase_worldBitangent = i.ase_texcoord4.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal19 = UnpackScaleNormal( tex2D( _NormalTex, uv_NormalTex ), _NormalScale );
				float3 worldNormal19 = normalize( float3(dot(tanToWorld0,tanNormal19), dot(tanToWorld1,tanNormal19), dot(tanToWorld2,tanNormal19)) );
				float fresnelNdotV16 = dot( normalize( worldNormal19 ), temp_cast_1 );
				float fresnelNode16 = ( 0.0 + 1.0 * pow( max( 1.0 - fresnelNdotV16 , 0.0001 ), 3.0 ) );
				float FrontMask13 = ( tex2DNode4.a * ( 1.0 - temp_output_8_0 ) );
				float CustomFresnel23 = ( fresnelNode16 * FrontMask13 );
				float2 appendResult54 = (float2(( ( pow( saferPower47 , 3.0 ) * BackMask1 ) + CustomFresnel23 ) , 0.5));
				float4 RumpColor56 = tex2D( _RumpTex, appendResult54 );
				float4 Albedo15 = tex2DNode4;
				
				
				finalColor = ( ( ( ( RumpColor56 * _RumpFrontIn ) + Albedo15 ) * FrontMask13 ) + ( ( Albedo15 + ( Albedo15 * RumpColor56 * _RumpBackIn ) ) * BackMask1 ) + ( Albedo15 * ( 1.0 - ( FrontMask13 + BackMask1 ) ) ) );
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
Node;AmplifyShaderEditor.CommentaryNode;76;-3148.89,283.983;Inherit;False;1511.024;303.1439;Comment;10;46;49;51;53;55;54;56;52;50;47;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;43;-3147.743,-297.9289;Inherit;False;1757.688;510.4225;Comment;14;27;30;31;32;33;34;38;39;40;41;35;36;37;42;CustomViewDir;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;27;-3018.686,-247.9289;Inherit;False;463.3865;237.0935;世界空间转模型空间;2;25;29;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;24;-3131.405,-820.3499;Inherit;False;1505.219;387.871;Comment;9;17;20;19;16;21;22;18;23;45;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;14;-1108.497,-776.3116;Inherit;False;1139.544;564.3888;Comment;11;4;5;10;7;9;8;11;12;13;1;15;Albedo/Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-459.0773,-726.3115;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;11;-520.0511,-405.5696;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-345.8517,-423.7694;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;8;-736.8892,-422.0283;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;5;-717.2505,-630.818;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;-728.8995,-723.129;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1;-213.6295,-704.53;Inherit;False;BackMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;13;-193.7519,-435.4695;Inherit;True;FrontMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;-1036.696,-459.3228;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;9;-1006.295,-349.4227;Inherit;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;20;-3073.405,-770.3499;Inherit;False;0;17;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;19;-2505.405,-707.3499;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FresnelNode;16;-2265.457,-712.8614;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-3081.405,-646.3499;Inherit;False;Property;_NormalScale;NormalScale;2;0;Create;True;0;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;17;-2796.405,-710.3499;Inherit;True;Property;_NormalTex;NormalTex;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;22;-2227.785,-547.879;Inherit;False;13;FrontMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;-1821.44,-703.9321;Inherit;False;CustomFresnel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-2023.187,-720.3723;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;25;-2967.193,-191.9552;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformDirectionNode;29;-2790.978,-188.9686;Inherit;False;World;Object;True;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;30;-3097.743,-1.299891;Inherit;False;Property;_RotateAngle;RotateAngle;3;0;Create;True;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;31;-2808.775,7.093829;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-3049.775,81.09384;Inherit;False;Constant;_Float1;Float 1;4;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-2661.775,11.09383;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;34;-2829.775,102.0938;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;38;-1783.772,-180.9062;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-1943.772,-130.9062;Inherit;False;Constant;_Float2;Float 2;4;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-1947.772,-55.90615;Inherit;False;Constant;_Float3;Float 3;4;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;41;-1588.772,-178.9062;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;35;-2485.151,-229.3084;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;36;-2239.874,-224.0332;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.FractNode;37;-2121.698,-226.3083;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;42;-1614.852,-48.97457;Inherit;False;ViewDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;-1058.496,-721.4206;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;0;False;0;False;-1;07dc1c6e78fc2e345bcc9d495c522bd0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;45;-2478.382,-541.7425;Inherit;False;42;ViewDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;3;-978.6973,-161.2493;Inherit;True;56;RumpColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;61;-842.5918,214.147;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;57;-1459.568,329.0797;Inherit;False;15;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-653.5918,274.147;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-1037.592,161.147;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-1264.237,194.7911;Inherit;False;Property;_RumpFrontIn;RumpFrontIn;4;0;Create;True;0;0;0;False;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-1185.14,521.4015;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-1411.785,555.0457;Inherit;False;Property;_RumpBackIn;RumpBackIn;5;0;Create;True;0;0;0;False;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;67;-955.5918,481.147;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-682.5918,496.147;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;59;-438.3667,392.8997;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;-269.5489,399.1017;Float;False;True;-1;2;ASEMaterialInspector;100;5;Card;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;0;5;False;;10;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;2;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;1;False;;True;3;False;;True;False;0;False;;0;False;;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;-1429.851,483.9938;Inherit;False;56;RumpColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;58;-1268.303,120.7393;Inherit;False;56;RumpColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;63;-904.5918,330.147;Inherit;False;13;FrontMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;69;-969.5918,588.147;Inherit;False;1;BackMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;71;-1459.592,762.147;Inherit;False;13;FrontMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;72;-1458.592,855.147;Inherit;False;1;BackMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;73;-1227.592,775.147;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;74;-1023.592,754.147;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-741.253,802.7118;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;-3098.89,360.4135;Inherit;False;42;ViewDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-2695.05,361.7966;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;51;-2485.785,363.1212;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;53;-2190.43,333.983;Inherit;True;Property;_RumpTex;RumpTex;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;55;-2459.295,469.0781;Inherit;False;Constant;_Float4;Float 4;6;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;54;-2328.174,361.7967;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;56;-1862.666,347.0521;Inherit;False;RumpColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;-2679.156,470.4025;Inherit;False;23;CustomFresnel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;50;-2895.043,471.7269;Inherit;False;1;BackMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;47;-2887.096,361.7967;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
WireConnection;10;0;5;0
WireConnection;10;1;8;0
WireConnection;11;0;8;0
WireConnection;12;0;5;0
WireConnection;12;1;11;0
WireConnection;8;0;7;1
WireConnection;8;1;9;0
WireConnection;5;0;4;4
WireConnection;15;0;4;0
WireConnection;1;0;10;0
WireConnection;13;0;12;0
WireConnection;19;0;17;0
WireConnection;16;0;19;0
WireConnection;16;4;45;0
WireConnection;17;1;20;0
WireConnection;17;5;18;0
WireConnection;23;0;21;0
WireConnection;21;0;16;0
WireConnection;21;1;22;0
WireConnection;29;0;25;0
WireConnection;31;0;30;0
WireConnection;31;1;32;0
WireConnection;33;0;31;0
WireConnection;33;1;34;0
WireConnection;38;0;37;0
WireConnection;38;1;39;0
WireConnection;38;2;40;0
WireConnection;41;0;38;0
WireConnection;35;0;29;0
WireConnection;35;2;33;0
WireConnection;36;0;35;0
WireConnection;37;0;36;0
WireConnection;42;0;41;0
WireConnection;61;0;60;0
WireConnection;61;1;57;0
WireConnection;62;0;61;0
WireConnection;62;1;63;0
WireConnection;60;0;58;0
WireConnection;60;1;48;0
WireConnection;65;0;57;0
WireConnection;65;1;64;0
WireConnection;65;2;66;0
WireConnection;67;0;57;0
WireConnection;67;1;65;0
WireConnection;68;0;67;0
WireConnection;68;1;69;0
WireConnection;59;0;62;0
WireConnection;59;1;68;0
WireConnection;59;2;75;0
WireConnection;0;0;59;0
WireConnection;73;0;71;0
WireConnection;73;1;72;0
WireConnection;74;0;73;0
WireConnection;75;0;57;0
WireConnection;75;1;74;0
WireConnection;49;0;47;0
WireConnection;49;1;50;0
WireConnection;51;0;49;0
WireConnection;51;1;52;0
WireConnection;53;1;54;0
WireConnection;54;0;51;0
WireConnection;54;1;55;0
WireConnection;56;0;53;0
WireConnection;47;0;46;0
ASEEND*/
//CHKSM=110995842C2B4C04377D85F1A69B74F000161D56