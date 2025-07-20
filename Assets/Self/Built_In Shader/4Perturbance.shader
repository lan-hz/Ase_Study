Shader "Perturbance"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _NoiseTex ("NoiseTex", 2D) = "white" {}
        Speed("Speed",vector) = (0,0,0,0)
        Intensity("Intensity",float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            float4 _MainTex_ST; 
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            float2 Speed;
            float Intensity;



            struct appdata
            {
                float4 vert : POSITION;
                float2 uv :TEXCOORD;
            };
            struct v2f
            {
                float4  pos :SV_POSITION;
                float2 uv :TEXCOORD; 
            };
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vert);
                o.uv = v.uv;
                return o;
            };
            fixed4 frag (v2f i) :SV_TARGET
            {
                float2 uv_MainTex = i.uv * _MainTex_ST.xy +_MainTex_ST.zw;
                float2 uv_Noise = i.uv * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
                
                float2 panner = _Time.y * Speed + uv_Noise;

                float2 pNoise = (tex2D(_NoiseTex,panner).r).xx;

                float2 col = lerp(uv_MainTex,pNoise,Intensity);

                float4 col2 =tex2D(_MainTex,col);

                return col2;
            } 
            ENDCG
        }
    }
}
