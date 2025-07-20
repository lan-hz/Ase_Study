// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Portal"
{
	Properties
	{
		_Rot("Rot", Vector) = (0,0,0,0)
		_Count("Count", Float) = 0
		_YRot("-YRot", Range( 0 , 1)) = 0
		_SmoothMin("SmoothMin", Float) = 0
		_SmoothMax("SmoothMax", Float) = 0
		_MainTex("MainTex", 2D) = "white" {}
		_NoiseTex("NoiseTex", 2D) = "white" {}
		_Timer("Timer", Float) = 0
		_DontTimer("DontTimer", Float) = 0
		_X_Intensity("X_Intensity", Float) = 1
		_Y_Intensity("Y_Intensity", Float) = 0
		_X_NoiseSpeed("X_NoiseSpeed", Float) = 1
		_Y_NoiseSpeed("Y_NoiseSpeed", Float) = 0
		_X_DontSpeed("X_DontSpeed", Float) = 1
		_Y_DontSpeed("Y_DontSpeed", Float) = 0
		_AddDoTex("AddDoTex", 2D) = "white" {}
		[HDR]_DontColor("DontColor", Color) = (1,1,1,1)
		_DontIntensity("DontIntensity", Float) = 0
		_MainTexIntensity("MainTexIntensity", Range( 0 , 10)) = 0.68
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord3( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 viewDir;
			float2 uv3_texcoord3;
		};

		uniform float3 _Rot;
		uniform float _Count;
		uniform float _YRot;
		uniform float _SmoothMin;
		uniform float _SmoothMax;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform sampler2D _NoiseTex;
		uniform float _Timer;
		uniform float _X_NoiseSpeed;
		uniform float _Y_NoiseSpeed;
		uniform float _X_Intensity;
		uniform float _Y_Intensity;
		uniform float _MainTexIntensity;
		uniform float4 _DontColor;
		uniform sampler2D _AddDoTex;
		uniform float _DontTimer;
		uniform float _X_DontSpeed;
		uniform float _Y_DontSpeed;
		uniform float4 _AddDoTex_ST;
		uniform float _DontIntensity;


		float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
		{
			original -= center;
			float C = cos( angle );
			float S = sin( angle );
			float t = 1 - C;
			float m00 = t * u.x * u.x + C;
			float m01 = t * u.x * u.y - S * u.z;
			float m02 = t * u.x * u.z + S * u.y;
			float m10 = t * u.x * u.y + S * u.z;
			float m11 = t * u.y * u.y + C;
			float m12 = t * u.y * u.z - S * u.x;
			float m20 = t * u.x * u.z - S * u.y;
			float m21 = t * u.y * u.z + S * u.x;
			float m22 = t * u.z * u.z + C;
			float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
			return mul( finalMatrix, original ) + center;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float RotationAngle12 = ( ( UNITY_PI / 180.0 ) * ( 360.0 * _Count ) );
			float temp_output_22_0 = (0.0 + (_YRot - 0.0) * (2.0 - 0.0) / (1.0 - 0.0));
			float smoothstepResult28 = smoothstep( _SmoothMin , _SmoothMax , abs( ( v.texcoord2.xy.x - 0.5 ) ));
			float temp_output_21_0 = ( temp_output_22_0 - smoothstepResult28 );
			float turn26 = ( RotationAngle12 * temp_output_22_0 * temp_output_21_0 );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 rotatedValue2 = RotateAroundAxis( float3( 0,0,0 ), ase_vertex3Pos, _Rot, min( RotationAngle12 , turn26 ) );
			float Alpha35 = saturate( temp_output_21_0 );
			float3 door67 = ( rotatedValue2 * Alpha35 );
			v.vertex.xyz = door67;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 color41 = IsGammaSpace() ? float4(1,1,1,1) : float4(1,1,1,1);
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float mulTime55 = _Time.y * _Timer;
			float2 appendResult62 = (float2(_X_NoiseSpeed , _Y_NoiseSpeed));
			float2 panner51 = ( mulTime55 * appendResult62 + uv_MainTex);
			float2 temp_cast_0 = (tex2D( _NoiseTex, panner51 ).r).xx;
			float2 appendResult66 = (float2(_X_Intensity , _Y_Intensity));
			float2 lerpResult63 = lerp( uv_MainTex , temp_cast_0 , appendResult66);
			float4 temp_cast_3 = (_MainTexIntensity).xxxx;
			float4 Emission70 = pow( ( color41 * tex2D( _MainTex, ( float3( lerpResult63 ,  0.0 ) + i.viewDir ).xy ) ) , temp_cast_3 );
			float mulTime80 = _Time.y * _DontTimer;
			float2 appendResult78 = (float2(_X_DontSpeed , _Y_DontSpeed));
			float2 uv_AddDoTex = i.uv_texcoord * _AddDoTex_ST.xy + _AddDoTex_ST.zw;
			float2 panner75 = ( mulTime80 * appendResult78 + uv_AddDoTex);
			float4 temp_cast_4 = (0.0).xxxx;
			float4 temp_cast_5 = (1.0).xxxx;
			float4 smoothstepResult94 = smoothstep( temp_cast_4 , temp_cast_5 , tex2D( _NoiseTex, panner51 ));
			float temp_output_22_0 = (0.0 + (_YRot - 0.0) * (2.0 - 0.0) / (1.0 - 0.0));
			float smoothstepResult28 = smoothstep( _SmoothMin , _SmoothMax , abs( ( i.uv3_texcoord3.x - 0.5 ) ));
			float temp_output_21_0 = ( temp_output_22_0 - smoothstepResult28 );
			float Alpha35 = saturate( temp_output_21_0 );
			float4 Dont89 = ( _DontColor * ( tex2D( _AddDoTex, panner75 ) * smoothstepResult94 * _DontIntensity ) * Alpha35 );
			o.Emission = ( Emission70 + Dont89 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float4 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.customPack1.zw = customInputData.uv3_texcoord3;
				o.customPack1.zw = v.texcoord2;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				surfIN.uv3_texcoord3 = IN.customPack1.zw;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;71;-2075.725,614.5366;Inherit;False;1968.032;746.3192;Comment;19;39;40;41;52;55;51;63;62;66;38;64;65;60;61;56;58;59;70;101;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;68;-2051.988,2673.293;Inherit;False;1347.883;504.9922;Door;9;2;4;25;11;27;3;36;37;67;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;32;-2067.694,1897.084;Inherit;False;1661.702;729.4071;Comment;15;35;21;33;31;30;28;26;24;23;22;15;18;16;20;17;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;10;-2064.211,1408.208;Inherit;False;812.9999;473.4999;旋转量;8;12;9;8;7;6;5;13;14;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;6;-1769.811,1476.408;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1976.512,1553.107;Inherit;False;Constant;_180;180;1;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;12;-1427.909,1580.408;Inherit;False;RotationAngle;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-1596.911,1566.106;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-1966.112,1653.207;Inherit;False;Constant;_360;360;1;0;Create;True;0;0;0;False;0;False;360;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-1725.611,1685.707;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;5;-2006.411,1458.207;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-1954.41,1768.908;Inherit;False;Property;_Count;Count;1;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;17;-1740.795,2140.237;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;20;-1472.995,2170.137;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1978.695,2275.437;Inherit;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-1890.227,1996.664;Inherit;False;Property;_YRot;-YRot;2;0;Create;True;0;0;0;False;0;False;0;0.6;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;22;-1518.967,1973.199;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-1114.896,2009.985;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;24;-1321.866,1947.084;Inherit;False;12;RotationAngle;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;26;-952.5657,2009.986;Inherit;False;turn;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;28;-1269.645,2294.649;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-1544.645,2419.649;Inherit;False;Property;_SmoothMin;SmoothMin;3;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-1547.645,2487.649;Inherit;False;Property;_SmoothMax;SmoothMax;4;0;Create;True;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;21;-1091.077,2205.221;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;33;-833.4838,2206.381;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;16;-2049.695,2108.637;Inherit;False;2;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;50;254.6613,976.5455;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Portal;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Absolute;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;2;-1443.13,2871.264;Inherit;False;False;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;4;-1762.929,2984.363;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMinOpNode;25;-1665.534,2881.628;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;11;-1982.789,2870.884;Inherit;False;12;RotationAngle;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;27;-1966.15,2944.428;Inherit;False;26;turn;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;3;-2001.988,2723.293;Inherit;False;Property;_Rot;Rot;0;0;Create;True;0;0;0;False;0;False;0,0,0;0.45,1,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;37;-1294.245,3062.885;Inherit;False;35;Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;67;-928.9052,2912.689;Inherit;False;door;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;69;-43.65232,1269.697;Inherit;False;67;door;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;39;-880.4472,997.4786;Inherit;True;Property;_MainTex;MainTex;5;0;Create;True;0;0;0;False;0;False;-1;None;6d5bfece2d65e9b4681dfc538c883003;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;41;-802.6082,828.412;Inherit;False;Constant;_Color0;Color 0;6;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;52;-1541.165,695.9421;Inherit;True;Property;_NoiseTex;NoiseTex;6;0;Create;True;0;0;0;False;0;False;-1;None;fa99af98603e9404c802419010acbbfd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;64;-1408.686,891.8932;Inherit;False;Property;_X_Intensity;X_Intensity;9;0;Create;True;0;0;0;False;0;False;1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-1407.686,977.8936;Inherit;False;Property;_Y_Intensity;Y_Intensity;10;0;Create;True;0;0;0;False;0;False;0;0.06;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;58;-1113.287,1107.456;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;59;-1405.504,1086.568;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;63;-1129.06,664.5367;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;66;-1209.552,913.6143;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;51;-1722.7,734.0967;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-2071.2,804.2704;Inherit;False;Property;_X_NoiseSpeed;X_NoiseSpeed;11;0;Create;True;0;0;0;False;0;False;1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-2063.799,885.4706;Inherit;False;Property;_Y_NoiseSpeed;Y_NoiseSpeed;12;0;Create;True;0;0;0;False;0;False;0;-0.26;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;62;-1890.799,809.2704;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-2056.125,963.0061;Inherit;False;Property;_Timer;Timer;7;0;Create;True;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;55;-1884.924,986.5722;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;78;-2092.791,287.0296;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;80;-2086.916,464.3315;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;38;-2040.938,656.7931;Inherit;False;0;39;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;73;-1759.608,147.399;Inherit;True;Property;_AddDoTex;AddDoTex;15;0;Create;True;0;0;0;False;0;False;-1;None;a1e1183c03dda8e4d9b1aa2bf7106580;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;90;57.31726,872.9808;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;72;-162.0339,852.7088;Inherit;False;70;Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;91;-156.4191,934.9045;Inherit;False;89;Dont;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-2273.191,282.0295;Inherit;False;Property;_X_DontSpeed;X_DontSpeed;13;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-2265.79,363.2296;Inherit;False;Property;_Y_DontSpeed;Y_DontSpeed;14;0;Create;True;0;0;0;False;0;False;0;-1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-2258.116,440.7653;Inherit;False;Property;_DontTimer;DontTimer;8;0;Create;True;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;75;-1977.295,170.1667;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;83;-1557.739,-92.5145;Inherit;False;Property;_DontColor;DontColor;16;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;0.1960784,1.552941,1.984314,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;95;-1527.551,489.1898;Inherit;False;Constant;_Float1;Float 1;18;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;96;-1524.551,556.1898;Inherit;False;Constant;_Float2;Float 2;18;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-1293.776,179.2644;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-1095.625,2899.507;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;89;-699.3454,45.73046;Inherit;False;Dont;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;93;-1119.265,408.035;Inherit;False;Property;_DontIntensity;DontIntensity;17;0;Create;True;0;0;0;False;0;False;0;0.12;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;94;-1346.475,408.3553;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;99;-1825.7,392.6904;Inherit;True;Property;_TextureSample0;Texture Sample 0;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;52;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;35;-682.1866,2204.249;Inherit;False;Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;100;-981.0132,284.4788;Inherit;False;35;Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-936.126,9.739801;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-544.0762,1021.667;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;70;-316.4858,1007.147;Inherit;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;101;-372.8086,1240.24;Inherit;True;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;102;-539.2109,1324.875;Inherit;False;Property;_MainTexIntensity;MainTexIntensity;18;0;Create;True;0;0;0;False;0;False;0.68;1.79;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;81;-2231.021,34.76298;Inherit;False;0;73;2;3;2;SAMPLER2D;;False;0;FLOAT2;10,10;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;6;0;5;0
WireConnection;6;1;7;0
WireConnection;12;0;8;0
WireConnection;8;0;6;0
WireConnection;8;1;14;0
WireConnection;14;0;9;0
WireConnection;14;1;13;0
WireConnection;17;0;16;1
WireConnection;17;1;18;0
WireConnection;20;0;17;0
WireConnection;22;0;15;0
WireConnection;23;0;24;0
WireConnection;23;1;22;0
WireConnection;23;2;21;0
WireConnection;26;0;23;0
WireConnection;28;0;20;0
WireConnection;28;1;30;0
WireConnection;28;2;31;0
WireConnection;21;0;22;0
WireConnection;21;1;28;0
WireConnection;33;0;21;0
WireConnection;50;2;90;0
WireConnection;50;11;69;0
WireConnection;2;0;3;0
WireConnection;2;1;25;0
WireConnection;2;3;4;0
WireConnection;25;0;11;0
WireConnection;25;1;27;0
WireConnection;67;0;36;0
WireConnection;39;1;58;0
WireConnection;52;1;51;0
WireConnection;58;0;63;0
WireConnection;58;1;59;0
WireConnection;63;0;38;0
WireConnection;63;1;52;1
WireConnection;63;2;66;0
WireConnection;66;0;64;0
WireConnection;66;1;65;0
WireConnection;51;0;38;0
WireConnection;51;2;62;0
WireConnection;51;1;55;0
WireConnection;62;0;60;0
WireConnection;62;1;61;0
WireConnection;55;0;56;0
WireConnection;78;0;76;0
WireConnection;78;1;77;0
WireConnection;80;0;79;0
WireConnection;73;1;75;0
WireConnection;90;0;72;0
WireConnection;90;1;91;0
WireConnection;75;0;81;0
WireConnection;75;2;78;0
WireConnection;75;1;80;0
WireConnection;86;0;73;0
WireConnection;86;1;94;0
WireConnection;86;2;93;0
WireConnection;36;0;2;0
WireConnection;36;1;37;0
WireConnection;89;0;84;0
WireConnection;94;0;99;0
WireConnection;94;1;95;0
WireConnection;94;2;96;0
WireConnection;99;1;51;0
WireConnection;35;0;33;0
WireConnection;84;0;83;0
WireConnection;84;1;86;0
WireConnection;84;2;100;0
WireConnection;40;0;41;0
WireConnection;40;1;39;0
WireConnection;70;0;101;0
WireConnection;101;0;40;0
WireConnection;101;1;102;0
ASEEND*/
//CHKSM=5FF258B2F22BB369C3A18C14EEDC0A9AAE759C3E