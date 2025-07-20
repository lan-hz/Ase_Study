Shader "Unlit/AgvElectric"
{
    Properties
    {
        [NoScaleOffset]_MainTex("主贴图", 2D) = "white" {}
        [NoScaleOffset]_RainTex("扰动贴图", 2D) = "white" {}
        [HDR]_SmoothColor("SmoothColor", Color) = (1, 1, 1, 1)
        [HDR]backgroundColor("背景色", Color) = (1, 1, 1, 1)
        ListNumber("竖列格数", Range(0, 20)) = 20
        _Smooth("Smooth", Range(0, 1)) = 1
        _NoiseSpeed("NoiseSpeed", Range(0, 10)) = 8
        _Power("渐变范围", Range(0, 1)) = 0
        _TexTilling("主图缩放", Range(0, 100)) = 10

    }
    SubShader
    {
        Tags {
        "RenderType" = "Transparent" "Queue" = "Transparent" }
        LOD 100

        Blend One One
        Cull Back
        ZWrite On


        Pass
        {
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #include "UnityCG.cginc"
            #include "UnityShaderVariables.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            sampler2D _RainTex;
            UNITY_INSTANCING_BUFFER_START(Props)

            float _Smooth;
            half ListNumber;
            float _NoiseSpeed;
            float _Power;
            float4 _SmoothColor;
            float4 backgroundColor;
            float _TexTilling;
            UNITY_INSTANCING_BUFFER_END(Props)

            float3 mod2D289(float3 x)
            {
                return x - floor(x * (1.0 / 289.0)) * 289.0;
            }
            float2 mod2D289(float2 x)
            {
                return x - floor(x * (1.0 / 289.0)) * 289.0;
            }
            float3 permute(float3 x)
            {
                return mod2D289(((x * 34.0) + 1.0) * x);
            }
            float snoise(float2 v)
            {
                const float4 C = float4(0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439);
                float2 i = floor(v + dot(v, C.yy));
                float2 x0 = v - i + dot(i, C.xx);
                float2 i1;
                i1 = (x0.x > x0.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
                float4 x12 = x0.xyxy + C.xxzz;
                x12.xy -= i1;
                i = mod2D289(i);
                float3 p = permute(permute(i.y + float3(0.0, i1.y, 1.0)) + i.x + float3(0.0, i1.x, 1.0));
                float3 m = max(0.5 - float3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
                m = m * m;
                m = m * m;
                float3 x = 2.0 * frac(p * C.www) - 1.0;
                float3 h = abs(x) - 0.5;
                float3 ox = floor(x + 0.5);
                float3 a0 = x - ox;
                m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);
                float3 g;
                g.x = a0.x * x0.x + h.x * x0.y;
                g.yz = a0.yz * x12.xz + h.yz * x12.yw;
                return 130.0 * dot(m, g);
            }

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);


                float _smooth = UNITY_ACCESS_INSTANCED_PROP(Props, _Smooth);
                half listNumber = UNITY_ACCESS_INSTANCED_PROP(Props, ListNumber);
                float _noiseSpeed = UNITY_ACCESS_INSTANCED_PROP(Props, _NoiseSpeed);
                float _power = UNITY_ACCESS_INSTANCED_PROP(Props, _Power);
                float4 _smoothColor = UNITY_ACCESS_INSTANCED_PROP(Props, _SmoothColor);
                float4 bgColor = UNITY_ACCESS_INSTANCED_PROP(Props, backgroundColor);
                float _texTilling = UNITY_ACCESS_INSTANCED_PROP(Props, _TexTilling);


                float2 uv = i.uv.xy;
                clip(0.999 - uv.y);


                half2 pixelatedUV = half2((int)(uv.x / (1 / listNumber)) * listNumber, (int)uv.y);

                float _noise = snoise(pixelatedUV * _noiseSpeed);

                _noise = _noise * 0.5 + 0.5;

                float2 panner = (-1.0 * _Time.y * _noise.xx + uv);
                float4 _noiseTex = tex2D(_RainTex, panner);

                float4 minSmooth = 0.2 + _smooth * (0.8 - 0.2);
                float4 smoothstepData = smoothstep(minSmooth, 1, _noiseTex);

                float2 texTilling = i.uv.xy * _texTilling;

                float4 mainTex = tex2D(_MainTex, texTilling);
                float4 data = (smoothstepData * mainTex * _smoothColor);

                float4 Alpha = (saturate(pow((1.0 - uv.y), (1.0 - (-2.0 + _power * (2.0 - -2.0))))) * bgColor);


                fixed4 col = (data + Alpha);

                return col;


            }
            ENDCG
        }
    }
}
