Shader"ENTI/02_Vertex_Unlit"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "WHITE" {}
        _Scale ("Scale", float) = 1.0
        _TilingOffset ("Tiling and Offset", vector) = (1.0, 1.0, 1.0, 1.0)
        _Displacement ("Displacement", float) = 1.0
        _RingThreshold ("Ring Threshold", float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
                float4 uv2 : TEXCOORD1;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };

            fixed4 _Color;
            float4 _MainTex_ST, _TilingOffset;
            sampler2D _MainTex;
            float _Displacement, _Scale, _RingThreshold;

            v2f vert(appdata v)
            {
                v2f o;
    
                float2 local_uv = v.uv;
                local_uv *= _TilingOffset.xy;
                local_uv += _TilingOffset.zw;
    
                o.uv = TRANSFORM_TEX(local_uv, _MainTex);
    
                /*
                //1. VISUALIZE COMPONENTS
    
                //normal
                o.color.xyz = v.normal * 0.5 + 0.5;
    
                //tangent
                o.color.xyz = v.tangent * 0.5 + 0.5;
    
                //bitanget
                float3 bitangent = cross(v.normal, v.tangent);
                o.color.xyz = bitangent * 0.5 + 0.5;
                o.color.w = 1.0;
    
                //uv
                o.color = float4(v.uv.xy, 0, 0);*/
    
                //2. DISPLACEMENTS
    
                o.vertex = UnityObjectToClipPos(v.vertex);
    
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                half4 col = tex2D(_MainTex, i.uv);
                col *= _Color;
                return col;
            }
            ENDCG
        }
    }
}
