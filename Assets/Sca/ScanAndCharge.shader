// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http :// u3d.as / y3X
Shader "ScanAndCharge"
{
    Properties
    {
        _MainTex("网格贴图", 2D) = "white" {}
        [NoScaleOffset]_Noise("波线贴图", 2D) = "white" {}
        [NoScaleOffset]_EdgeTex("边缘光贴图", 2D) = "white" {}
        [HDR]_UvColor("背景色", Color) = (1, 1, 1, 1)
        [HDR]_MainColor("网格颜色", Color) = (1, 1, 1, 1)
        [HDR]_NoiseColor("波线颜色", Color) = (0, 0, 0, 0)
        _Power("渐变范围", Range(0, 1)) = 1
        _NoiseSpeed("波动速度", Float) = 1
        _PaintIntensidy("背景色强度", Range(0, 1)) = 0
        _NoiseTilling("波线数量", Range(0, 20)) = 1
        [Toggle]_ToggleSwitch0("Toggle Switch0", Float) = 1
        [HDR]ChargeColor("电量颜色", Color) = (0, 0, 0, 0)
        ChargeNoiseTex("充电扰动", 2D) = "white" {}
        _Angle("电量", Range(0, 100)) = 0
        _Ply("环宽度", Range(0, 50)) = 3.23
        _Speed("扰动速度", Range(0, 3)) = 0.5
        [HDR]ChargeNoiseColor("充电扰动颜色", Color) = (1, 1, 1, 1)
        _Intens("底环透明度", Range(0, 1)) = 0
        [HideInInspector] _texcoord("", 2D) = "white" {}

    }

    SubShader
    {


        Tags {
        "RenderType" = "Opaque" "Queue" = "Transparent" }
        LOD 100

        CGINCLUDE
        #pragma target 3.0
        ENDCG
        Blend SrcAlpha OneMinusSrcAlpha
        AlphaToMask Off
        Cull Back
        ColorMask RGBA
        ZWrite On
        ZTest LEqual



        Pass
        {
            Name "Unlit"

            CGPROGRAM

            #define ASE_ABSOLUTE_VERTEX_POS 1


            #ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
                // only defining to not throw compilation error over Unity 5.5
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
                float4 ase_texcoord1 : TEXCOORD1;
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

            uniform float _ToggleSwitch0;
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
            uniform float4 ChargeColor;
            uniform half _Angle;
            uniform half _Ply;
            uniform half _Intens;
            uniform float4 ChargeNoiseColor;
            uniform sampler2D ChargeNoiseTex;
            uniform half _Speed;


            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                o.ase_texcoord1 = v.ase_texcoord;
                o.ase_texcoord2.xy = v.ase_texcoord1.xy;

                // setting value to unused interpolator channels and avoid initialization warnings
                o.ase_texcoord2.zw = 0;
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

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                fixed4 finalColor;
                #ifdef ASE_NEEDS_FRAG_WORLD_POSITION
                    float3 WorldPosition = i.worldPos;
                #endif
                float2 uv_MainTex = i.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                float4 texCoord22 = i.ase_texcoord1;
                texCoord22.xy = i.ase_texcoord1.xy * float2(1, 1) + float2(0, 0);
                float Alpha44 = saturate(pow(texCoord22.y, (1.0 - (-2.0 + (_Power - 0.0) * (1.0 - -2.0) / (1.0 - 0.0)))));
                float4 MainTex45 = (_MainColor * tex2D(_MainTex, uv_MainTex) * Alpha44);
                float2 uv_EdgeTex61 = i.ase_texcoord1.xy;
                float4 Back50 = (_UvColor * (tex2D(_EdgeTex, uv_EdgeTex61) + (0.0 + (_PaintIntensidy - 0.0) * (0.5 - 0.0) / (1.0 - 0.0))) * Alpha44);
                float2 temp_cast_0 = (_NoiseSpeed).xx;
                float2 texCoord15 = i.ase_texcoord1.xy * float2(1, 1) + float2(0, 0);
                clip(0.999 - texCoord15.y);
                float2 panner13 = (_Time.y * temp_cast_0 + (texCoord15 * _NoiseTilling));
                float4 Noise48 = (tex2D(_Noise, panner13) * Alpha44 * _NoiseColor);
                float4 appendResult31 = (float4((MainTex45 + Back50 + Noise48).rgb, Alpha44));

                float2 texCoord87 = i.ase_texcoord1.xy * float2(100, 100) + float2(0, 0);
                float temp_output_106_0 = step((100.0 + (_Angle - 0.0) * (0.0 - 100.0) / (100.0 - 0.0)), texCoord87.x);
                float temp_output_92_0 = step(texCoord87.y, _Ply);
                float temp_output_89_0 = ((1.0 - temp_output_106_0) * temp_output_92_0);
                float4 temp_cast_3 = ((temp_output_89_0 * _Intens)).xxxx;
                float2 temp_cast_4 = (_Speed).xx;
                float2 texCoord104 = i.ase_texcoord2.xy * float2(0.5, 0) + float2(0, 0);
                float2 temp_cast_5 = (texCoord104.x).xx;
                float2 panner94 = (1.0 * _Time.y * temp_cast_4 + temp_cast_5);
                float4 lerpResult102 = lerp(temp_cast_3, ChargeNoiseColor, tex2D(ChargeNoiseTex, panner94).r);
                float4 Charge107 = ((ChargeColor * temp_output_106_0 * temp_output_92_0) + (temp_output_89_0 * lerpResult102));


                finalColor = ((_ToggleSwitch0)?(Charge107) : (appendResult31));
                return finalColor;
            }
            ENDCG
        }
    }
    CustomEditor "ASEMaterialInspector"

    Fallback Off
}
/*ASEBEGIN
Version = 19105
Node; AmplifyShaderEditor.CommentaryNode; 63; -674.6545, -757.6898; Inherit; False; 1075.249; 576.1306; Comment; 6; 3; 53; 1; 4; 2; 45; ; 1, 1, 1, 1; 0; 0
Node; AmplifyShaderEditor.CommentaryNode; 62; -736.5678, -136.0999; Inherit; False; 1206.01; 539.2045; Comment; 7; 70; 68; 61; 8; 6; 54; 66; Back; 1, 1, 1, 1; 0; 0
Node; AmplifyShaderEditor.CommentaryNode; 59; -948.649, 546.3527; Inherit; False; 1611.791; 582.5372; Comment; 12; 13; 20; 18; 74; 76; 21; 80; 55; 34; 48; 85; 15; Noise; 1, 1, 1, 1; 0; 0
Node; AmplifyShaderEditor.CommentaryNode; 58; -782.0643, 1173.102; Inherit; False; 1038.867; 390.5434; Comment; 7; 44; 27; 41; 81; 26; 25; 22; Alpha; 1, 1, 1, 1; 0; 0
Node; AmplifyShaderEditor.RegisterLocalVarNode; 48; 439.1418, 660.3018; Inherit; False; Noise; -1; True; 1; 0; COLOR; 0, 0, 0, 0; False; 1; COLOR; 0
Node; AmplifyShaderEditor.SimpleMultiplyOpNode; 34; 247.7042, 647.9142; Inherit; False; 3; 3; 0; COLOR; 0, 0, 0, 0; False; 1; FLOAT; 0; False; 2; COLOR; 0, 0, 0, 0; False; 1; COLOR; 0
Node; AmplifyShaderEditor.GetLocalVarNode; 53; -177.2545, -297.5594; Inherit; False; 44; Alpha; 1; 0; OBJECT; ; False; 1; FLOAT; 0
Node; AmplifyShaderEditor.SimpleMultiplyOpNode; 4; 1.901411, -523.3875; Inherit; False; 3; 3; 0; COLOR; 0, 0, 0, 0; False; 1; COLOR; 0, 0, 0, 0; False; 2; FLOAT; 0; False; 1; COLOR; 0
Node; AmplifyShaderEditor.RegisterLocalVarNode; 45; 176.5946, -498.9892; Inherit; False; MainTex; -1; True; 1; 0; COLOR; 0, 0, 0, 0; False; 1; COLOR; 0
Node; AmplifyShaderEditor.GetLocalVarNode; 55; 6.457399, 823.1301; Inherit; False; 44; Alpha; 1; 0; OBJECT; ; False; 1; FLOAT; 0
Node; AmplifyShaderEditor.ColorNode; 3; -331.6645, -707.6898; Inherit; False; Property; _MainColor; 网格颜色; 4; 1; [HDR]; Create; False; 0; 0; 0; False; 0; False; 1, 1, 1, 1; 0, 0.9528302, 0.3195121, 1; True; 0; 5; COLOR; 0; FLOAT; 1; FLOAT; 2; FLOAT; 3; FLOAT; 4
Node; AmplifyShaderEditor.ColorNode; 80; 225.79, 790.5558; Inherit; False; Property; _NoiseColor; 波线颜色; 5; 1; [HDR]; Create; False; 0; 0; 0; False; 0; False; 0, 0, 0, 0; 1, 1, 1, 0; True; 0; 5; COLOR; 0; FLOAT; 1; FLOAT; 2; FLOAT; 3; FLOAT; 4
Node; AmplifyShaderEditor.SamplerNode; 21; -82.57396, 625.1871; Inherit; True; Property; _Noise; 波线贴图; 1; 1; [NoScaleOffset]; Create; False; 0; 0; 0; False; 0; False; -1; 9d9fc823d25de2542b7e6daa2f8a6721; 9d9fc823d25de2542b7e6daa2f8a6721; True; 0; False; white; Auto; False; Object; -1; Auto; Texture2D; 8; 0; SAMPLER2D; ; False; 1; FLOAT2; 0, 0; False; 2; FLOAT; 0; False; 3; FLOAT2; 0, 0; False; 4; FLOAT2; 0, 0; False; 5; FLOAT; 1; False; 6; FLOAT; 0; False; 7; SAMPLERSTATE; ; False; 5; COLOR; 0; FLOAT; 1; FLOAT; 2; FLOAT; 3; FLOAT; 4
Node; AmplifyShaderEditor.SimpleAddOpNode; 66; -104.163, 86.29352; Inherit; False; 2; 2; 0; COLOR; 0, 0, 0, 0; False; 1; FLOAT; 0; False; 1; COLOR; 0
Node; AmplifyShaderEditor.GetLocalVarNode; 54; -16.81839, 209.8365; Inherit; False; 44; Alpha; 1; 0; OBJECT; ; False; 1; FLOAT; 0
Node; AmplifyShaderEditor.SimpleMultiplyOpNode; 6; 138.1613, -87.90285; Inherit; True; 3; 3; 0; COLOR; 0, 0, 0, 0; False; 1; COLOR; 0, 0, 0, 0; False; 2; FLOAT; 0; False; 1; COLOR; 0
Node; AmplifyShaderEditor.ColorNode; 8; -667.4743, -79.313; Inherit; False; Property; _UvColor; 背景色; 3; 1; [HDR]; Create; False; 0; 0; 0; False; 0; False; 1, 1, 1, 1; 1, 1, 1, 1; True; 0; 5; COLOR; 0; FLOAT; 1; FLOAT; 2; FLOAT; 3; FLOAT; 4
Node; AmplifyShaderEditor.SamplerNode; 61; -425.9278, -10.90987; Inherit; True; Property; _EdgeTex; 边缘光贴图; 2; 1; [NoScaleOffset]; Create; False; 0; 0; 0; False; 0; False; -1; None; None; True; 0; False; white; Auto; False; Object; -1; Auto; Texture2D; 8; 0; SAMPLER2D; ; False; 1; FLOAT2; 0, 0; False; 2; FLOAT; 0; False; 3; FLOAT2; 0, 0; False; 4; FLOAT2; 0, 0; False; 5; FLOAT; 1; False; 6; FLOAT; 0; False; 7; SAMPLERSTATE; ; False; 5; COLOR; 0; FLOAT; 1; FLOAT; 2; FLOAT; 3; FLOAT; 4
Node; AmplifyShaderEditor.TextureCoordinatesNode; 22; -732.0645, 1229.891; Inherit; False; 0; -1; 4; 3; 2; SAMPLER2D; ; False; 0; FLOAT2; 1, 1; False; 1; FLOAT2; 0, 0; False; 5; FLOAT4; 0; FLOAT; 1; FLOAT; 2; FLOAT; 3; FLOAT; 4
Node; AmplifyShaderEditor.SamplerNode; 1; -364.3975, -531.3837; Inherit; True; Property; _MainTex; 网格贴图; 0; 0; Create; False; 0; 0; 0; False; 0; False; -1; 8658aef8910eaef47b6d78fc2704ea08; 8658aef8910eaef47b6d78fc2704ea08; True; 0; False; white; Auto; False; Object; -1; Auto; Texture2D; 8; 0; SAMPLER2D; ; False; 1; FLOAT2; 0, 0; False; 2; FLOAT; 0; False; 3; FLOAT2; 0, 0; False; 4; FLOAT2; 0, 0; False; 5; FLOAT; 1; False; 6; FLOAT; 0; False; 7; SAMPLERSTATE; ; False; 5; COLOR; 0; FLOAT; 1; FLOAT; 2; FLOAT; 3; FLOAT; 4
Node; AmplifyShaderEditor.TextureCoordinatesNode; 2; -624.6545, -517.6206; Inherit; False; 0; 1; 2; 3; 2; SAMPLER2D; ; False; 0; FLOAT2; 1, 1; False; 1; FLOAT2; 0, 0; False; 5; FLOAT2; 0; FLOAT; 1; FLOAT; 2; FLOAT; 3; FLOAT; 4
Node; AmplifyShaderEditor.RangedFloatNode; 68; -637.3979, 183.6268; Inherit; False; Property; _PaintIntensidy; 背景色强度; 8; 0; Create; False; 0; 0; 0; False; 0; False; 0; 0; 0; 1; 0; 1; FLOAT; 0
Node; AmplifyShaderEditor.TFHCRemapNode; 70; -277.6112, 176.8055; Inherit; False; 5; 0; FLOAT; 0; False; 1; FLOAT; 0; False; 2; FLOAT; 1; False; 3; FLOAT; 0; False; 4; FLOAT; 0.5; False; 1; FLOAT; 0
Node; AmplifyShaderEditor.PannerNode; 13; -304.4566, 847.8037; Inherit; True; 3; 0; FLOAT2; 0, 0; False; 2; FLOAT2; 1, 1; False; 1; FLOAT; 1; False; 1; FLOAT2; 0
Node; AmplifyShaderEditor.SimpleTimeNode; 20; -550.0032, 1001.888; Inherit; False; 1; 0; FLOAT; 1; False; 1; FLOAT; 0
Node; AmplifyShaderEditor.RangedFloatNode; 18; -548.2053, 924.2868; Inherit; False; Property; _NoiseSpeed; 波动速度; 7; 0; Create; False; 0; 0; 0; False; 0; False; 1; 0.5; 0; 0; 0; 1; FLOAT; 0
Node; AmplifyShaderEditor.RangedFloatNode; 76; -801.8425, 812.8925; Inherit; False; Property; _NoiseTilling; 波线数量; 9; 0; Create; False; 0; 0; 0; False; 0; False; 1; 3; 0; 20; 0; 1; FLOAT; 0
Node; AmplifyShaderEditor.SimpleMultiplyOpNode; 74; -413.6091, 725.0786; Inherit; False; 2; 2; 0; FLOAT2; 0, 0; False; 1; FLOAT; 0; False; 1; FLOAT2; 0
Node; AmplifyShaderEditor.ClipNode; 85; -675.3657, 587.2825; Inherit; True; 3; 0; FLOAT2; 0, 0; False; 1; FLOAT; 0.999; False; 2; FLOAT; 0; False; 1; FLOAT2; 0
Node; AmplifyShaderEditor.TextureCoordinatesNode; 15; -898.8093, 603.1498; Inherit; False; 0; -1; 2; 3; 2; SAMPLER2D; ; False; 0; FLOAT2; 1, 1; False; 1; FLOAT2; 0, 0; False; 5; FLOAT2; 0; FLOAT; 1; FLOAT; 2; FLOAT; 3; FLOAT; 4
Node; AmplifyShaderEditor.PowerNode; 25; -334.5608, 1243.492; Inherit; False; False; 2; 0; FLOAT; 0; False; 1; FLOAT; 1; False; 1; FLOAT; 0
Node; AmplifyShaderEditor.RangedFloatNode; 26; -774.4477, 1402.272; Inherit; False; Property; _Power; 渐变范围; 6; 0; Create; False; 0; 0; 0; False; 0; False; 1; 1; 0; 1; 0; 1; FLOAT; 0
Node; AmplifyShaderEditor.TFHCRemapNode; 81; -487.0125, 1391.325; Inherit; False; 5; 0; FLOAT; 0; False; 1; FLOAT; 0; False; 2; FLOAT; 1; False; 3; FLOAT; -2; False; 4; FLOAT; 1; False; 1; FLOAT; 0
Node; AmplifyShaderEditor.OneMinusNode; 41; -297.6309, 1405.137; Inherit; False; 1; 0; FLOAT; 0; False; 1; FLOAT; 0
Node; AmplifyShaderEditor.SaturateNode; 27; -147.9642, 1243.213; Inherit; True; 1; 0; FLOAT; 0; False; 1; FLOAT; 0
Node; AmplifyShaderEditor.RegisterLocalVarNode; 44; 56.60426, 1245.195; Inherit; False; Alpha; -1; True; 1; 0; FLOAT; 0; False; 1; FLOAT; 0
Node; AmplifyShaderEditor.CommentaryNode; 86; 1179.856, 26.4517; Inherit; False; 2249.935; 1061.293; Comment; 21; 106; 105; 104; 103; 102; 101; 100; 99; 98; 97; 96; 95; 94; 93; 92; 91; 90; 89; 88; 87; 107; 充电; 1, 1, 1, 1; 0; 0
Node; AmplifyShaderEditor.SimpleMultiplyOpNode; 89; 2241.355, 424.1599; Inherit; True; 2; 2; 0; FLOAT; 0; False; 1; FLOAT; 0; False; 1; FLOAT; 0
Node; AmplifyShaderEditor.SimpleMultiplyOpNode; 90; 2580.811, 583.4694; Inherit; False; 2; 2; 0; FLOAT; 0; False; 1; FLOAT; 0; False; 1; FLOAT; 0
Node; AmplifyShaderEditor.OneMinusNode; 91; 2052.133, 241.7445; Inherit; False; 1; 0; FLOAT; 0; False; 1; FLOAT; 0
Node; AmplifyShaderEditor.StepOpNode; 92; 1620.438, 479.6674; Inherit; True; 2; 0; FLOAT; 0; False; 1; FLOAT; 0; False; 1; FLOAT; 0
Node; AmplifyShaderEditor.SimpleMultiplyOpNode; 95; 2490.32, 215.7625; Inherit; True; 3; 3; 0; COLOR; 0, 0, 0, 0; False; 1; FLOAT; 0; False; 2; FLOAT; 0; False; 1; COLOR; 0
Node; AmplifyShaderEditor.RangedFloatNode; 98; 1289.256, 442.504; Half; False; Property; _Ply; 环宽度; 14; 0; Create; False; 0; 0; 0; False; 0; False; 3.23; 5; 0; 50; 0; 1; FLOAT; 0
Node; AmplifyShaderEditor.RangedFloatNode; 99; 2207.45, 657.481; Half; False; Property; _Intens; 底环透明度; 17; 0; Create; False; 0; 0; 0; False; 0; False; 0; 0.512; 0; 1; 0; 1; FLOAT; 0
Node; AmplifyShaderEditor.SimpleMultiplyOpNode; 101; 2919.475, 611.8903; Inherit; False; 2; 2; 0; FLOAT; 0; False; 1; COLOR; 0, 0, 0, 0; False; 1; COLOR; 0
Node; AmplifyShaderEditor.LerpOp; 102; 2696.128, 773.3091; Inherit; True; 3; 0; COLOR; 0, 0, 0, 0; False; 1; COLOR; 0, 0, 0, 0; False; 2; FLOAT; 0; False; 1; COLOR; 0
Node; AmplifyShaderEditor.TextureCoordinatesNode; 104; 1362.888, 861.7111; Inherit; False; 1; -1; 2; 3; 2; SAMPLER2D; ; False; 0; FLOAT2; 0.1, 0; False; 1; FLOAT2; 0, 0; False; 5; FLOAT2; 0; FLOAT; 1; FLOAT; 2; FLOAT; 3; FLOAT; 4
Node; AmplifyShaderEditor.StepOpNode; 106; 1839.863, 203.1742; Inherit; True; 2; 0; FLOAT; 0; False; 1; FLOAT; 0; False; 1; FLOAT; 0
Node; AmplifyShaderEditor.PannerNode; 94; 1649.588, 872.0007; Inherit; True; 3; 0; FLOAT2; 0, 0; False; 2; FLOAT2; 0, 0; False; 1; FLOAT; 1; False; 1; FLOAT2; 0
Node; AmplifyShaderEditor.RegisterLocalVarNode; 50; 349.3329, -67.82127; Inherit; False; Back; -1; True; 1; 0; COLOR; 0, 0, 0, 0; False; 1; COLOR; 0
Node; AmplifyShaderEditor.DynamicAppendNode; 31; 1487.342, -756.1071; Inherit; True; FLOAT4; 4; 0; FLOAT3; 0, 0, 0; False; 1; FLOAT; 0; False; 2; FLOAT; 0; False; 3; FLOAT; 0; False; 1; FLOAT4; 0
Node; AmplifyShaderEditor.SimpleAddOpNode; 12; 1166.623, -795.4944; Inherit; True; 3; 3; 0; COLOR; 0, 0, 0, 0; False; 1; COLOR; 0, 0, 0, 0; False; 2; COLOR; 0, 0, 0, 0; False; 1; COLOR; 0
Node; AmplifyShaderEditor.GetLocalVarNode; 51; 985.0533, -504.1149; Inherit; False; 44; Alpha; 1; 0; OBJECT; ; False; 1; FLOAT; 0
Node; AmplifyShaderEditor.GetLocalVarNode; 56; 889.5953, -715.9983; Inherit; False; 50; Back; 1; 0; OBJECT; ; False; 1; COLOR; 0
Node; AmplifyShaderEditor.GetLocalVarNode; 57; 901.8492, -615.5168; Inherit; False; 48; Noise; 1; 0; OBJECT; ; False; 1; COLOR; 0
Node; AmplifyShaderEditor.GetLocalVarNode; 52; 907.601, -807.8618; Inherit; False; 45; MainTex; 1; 0; OBJECT; ; False; 1; COLOR; 0
Node; AmplifyShaderEditor.SimpleAddOpNode; 88; 3086.491, 520.8951; Inherit; True; 2; 2; 0; COLOR; 0, 0, 0, 0; False; 1; COLOR; 0, 0, 0, 0; False; 1; COLOR; 0
Node; AmplifyShaderEditor.ToggleSwitchNode; 108; 1851.619, -676.4265; Inherit; False; Property; _ToggleSwitch0; Toggle Switch0; 10; 0; Create; True; 0; 0; 0; False; 0; False; 1; True; 2; 0; COLOR; 0, 0, 0, 0; False; 1; COLOR; 0, 0, 0, 0; False; 1; COLOR; 0
Node; AmplifyShaderEditor.GetLocalVarNode; 109; 1721.017, -544.0358; Inherit; False; 107; Charge; 1; 0; OBJECT; ; False; 1; COLOR; 0
Node; AmplifyShaderEditor.TemplateMultiPassMasterNode; 0; 2160.184, -790.8652; Float; False; True; -1; 2; ASEMaterialInspector; 100; 5; ScanAndCharge; 0770190933193b94aaa3065e307002fa; True; Unlit; 0; 0; Unlit; 2; True; True; 2; 5; False; ; 10; False; ; 0; 1; False; ; 0; False; ; True; 0; False; ; 0; False; ; False; False; False; False; False; False; False; False; False; True; 0; False; ; False; True; 0; False; ; False; True; True; True; True; True; 0; False; ; False; False; False; False; False; False; False; True; False; 0; False; ; 255; False; ; 255; False; ; 0; False; ; 0; False; ; 0; False; ; 0; False; ; 0; False; ; 0; False; ; 0; False; ; 0; False; ; True; True; 1; False; ; True; 3; False; ; True; False; 0; False; ; 0; False; ; True; 2; RenderType = Opaque = RenderType; Queue = Transparent = Queue = 0; True; 2; False; 0; False; False; False; False; False; False; False; False; False; False; False; False; False; False; False; False; False; False; False; False; False; False; False; False; False; False; False; False; False; False; False; False; 0; ; 0; 0; Standard; 1; Vertex Position, InvertActionOnDeselection; 0; 638463462673822190; 0; 1; True; False; ; False; 0
Node; AmplifyShaderEditor.SamplerNode; 103; 1965.278, 872.1696; Inherit; True; Property; ChargeNoiseTex; 充电扰动; 12; 0; Create; False; 0; 0; 0; False; 0; False; -1; 9d9fc823d25de2542b7e6daa2f8a6721; 482ce6055bd4dbb4ab6be41eec2d2250; True; 0; False; white; Auto; False; Object; -1; Auto; Texture2D; 8; 0; SAMPLER2D; ; False; 1; FLOAT2; 0, 0; False; 2; FLOAT; 0; False; 3; FLOAT2; 0, 0; False; 4; FLOAT2; 0, 0; False; 5; FLOAT; 1; False; 6; FLOAT; 0; False; 7; SAMPLERSTATE; ; False; 5; COLOR; 0; FLOAT; 1; FLOAT; 2; FLOAT; 3; FLOAT; 4
Node; AmplifyShaderEditor.TFHCRemapNode; 105; 1655.618, 39.71383; Inherit; False; 5; 0; FLOAT; 0; False; 1; FLOAT; 0; False; 2; FLOAT; 100; False; 3; FLOAT; 100; False; 4; FLOAT; 0; False; 1; FLOAT; 0
Node; AmplifyShaderEditor.RangedFloatNode; 100; 1290.607, 77.84709; Half; False; Property; _Angle; 电量; 13; 0; Create; False; 1; 充电; 0; 0; False; 0; False; 0; 67.07332; 0; 100; 0; 1; FLOAT; 0
Node; AmplifyShaderEditor.TextureCoordinatesNode; 87; 1388.681, 166.0954; Inherit; False; 0; -1; 2; 3; 2; SAMPLER2D; ; False; 0; FLOAT2; 100, 100; False; 1; FLOAT2; 0, 0; False; 5; FLOAT2; 0; FLOAT; 1; FLOAT; 2; FLOAT; 3; FLOAT; 4
Node; AmplifyShaderEditor.RangedFloatNode; 97; 1338.777, 991.2281; Half; False; Property; _Speed; 扰动速度; 15; 0; Create; False; 0; 0; 0; False; 0; False; 0.5; 0.85; 0; 3; 0; 1; FLOAT; 0
Node; AmplifyShaderEditor.RegisterLocalVarNode; 107; 3332.316, 524.3953; Inherit; False; Charge; -1; True; 1; 0; COLOR; 0, 0, 0, 0; False; 1; COLOR; 0
Node; AmplifyShaderEditor.ColorNode; 96; 2213.231, 70.11429; Inherit; False; Property; ChargeColor; 电量颜色; 11; 1; [HDR]; Create; False; 0; 0; 0; False; 0; False; 0, 0, 0, 0; 0, 2, 0.2117647, 1; True; 0; 5; COLOR; 0; FLOAT; 1; FLOAT; 2; FLOAT; 3; FLOAT; 4
Node; AmplifyShaderEditor.ColorNode; 93; 2218.005, 746.421; Inherit; False; Property; ChargeNoiseColor; 充电扰动颜色; 16; 1; [HDR]; Create; False; 0; 0; 0; False; 0; False; 1, 1, 1, 1; 0, 1, 0.6757278, 1; True; 0; 5; COLOR; 0; FLOAT; 1; FLOAT; 2; FLOAT; 3; FLOAT; 4
WireConnection; 48; 0; 34; 0
WireConnection; 34; 0; 21; 0
WireConnection; 34; 1; 55; 0
WireConnection; 34; 2; 80; 0
WireConnection; 4; 0; 3; 0
WireConnection; 4; 1; 1; 0
WireConnection; 4; 2; 53; 0
WireConnection; 45; 0; 4; 0
WireConnection; 21; 1; 13; 0
WireConnection; 66; 0; 61; 0
WireConnection; 66; 1; 70; 0
WireConnection; 6; 0; 8; 0
WireConnection; 6; 1; 66; 0
WireConnection; 6; 2; 54; 0
WireConnection; 1; 1; 2; 0
WireConnection; 70; 0; 68; 0
WireConnection; 13; 0; 74; 0
WireConnection; 13; 2; 18; 0
WireConnection; 13; 1; 20; 0
WireConnection; 74; 0; 85; 0
WireConnection; 74; 1; 76; 0
WireConnection; 85; 0; 15; 0
WireConnection; 85; 2; 15; 2
WireConnection; 25; 0; 22; 2
WireConnection; 25; 1; 41; 0
WireConnection; 81; 0; 26; 0
WireConnection; 41; 0; 81; 0
WireConnection; 27; 0; 25; 0
WireConnection; 44; 0; 27; 0
WireConnection; 89; 0; 91; 0
WireConnection; 89; 1; 92; 0
WireConnection; 90; 0; 89; 0
WireConnection; 90; 1; 99; 0
WireConnection; 91; 0; 106; 0
WireConnection; 92; 0; 87; 2
WireConnection; 92; 1; 98; 0
WireConnection; 95; 0; 96; 0
WireConnection; 95; 1; 106; 0
WireConnection; 95; 2; 92; 0
WireConnection; 101; 0; 89; 0
WireConnection; 101; 1; 102; 0
WireConnection; 102; 0; 90; 0
WireConnection; 102; 1; 93; 0
WireConnection; 102; 2; 103; 1
WireConnection; 106; 0; 105; 0
WireConnection; 106; 1; 87; 1
WireConnection; 94; 0; 104; 1
WireConnection; 94; 2; 97; 0
WireConnection; 50; 0; 6; 0
WireConnection; 31; 0; 12; 0
WireConnection; 31; 3; 51; 0
WireConnection; 12; 0; 52; 0
WireConnection; 12; 1; 56; 0
WireConnection; 12; 2; 57; 0
WireConnection; 88; 0; 95; 0
WireConnection; 88; 1; 101; 0
WireConnection; 108; 0; 31; 0
WireConnection; 108; 1; 109; 0
WireConnection; 0; 0; 108; 0
WireConnection; 103; 1; 94; 0
WireConnection; 105; 0; 100; 0
WireConnection; 107; 0; 88; 0
ASEEND*/
// CHKSM = 5A09FED65E824367FF7EF1F97CA11E08651F2B1D
