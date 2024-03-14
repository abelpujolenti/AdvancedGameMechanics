Shader"ENTI/10_PhongNormal"
{
    Properties
    {
        _MainTexture("Main Texture", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "white" {}
        _NormalStrength("Normal Strength", Range(0, 5)) = 1.0

        [Space(1)]
        [Header(Diffuse)]
        _Attenuation("Attenuation", Range(0.001,5)) = 1.0

        [Space(1)]
        [Header(Ambient)]
        _Color("Ambient Color", Color) = (1,1,1,1)
        _AmbientIntensity("Ambient Intensity", Range(0.001,5)) = 1.0

        [Space(1)]
        [Header(Specular)]
        _SpecColor("Specular Color", Color) = (1,1,1,1)
        _SpecPow("Specular Power", Range(0.001,20)) = 1.0
        _SpecIntensity("Specular Intensity", Range(1,5)) = 1.0

        [Space(1)]
        [Header(Outline)]
        _OutlineWidth("Outline Width", float) = 1.0
    }
        SubShader
        {
            Tags { "LightMode" = "ForwardBase" }

            Pass
            {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "UnityCG.cginc"


                struct appdata
                {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float2 uv : TEXCOORD0;

                    float4 tangent : TANGENT;
                };

                struct v2f
                {
                    float4 vertex : SV_POSITION;
                    float3 normal : NORMAL;
                    float2 uv : TEXCOORD0;
                    float3 viewdir : TEXCOORD1;
                    float4 col : COLOR;

                    float3 tangent : TEXCOORD2;
                    float3 binormal : TEXCOORD3;
                };

                sampler2D _MainTexture, _NormalMap;
                float4 _MainTexture_ST, _NormalMap_ST;
                fixed4 _Color, _SpecColor, _ShadowColor;
                float _Attenuation, _AmbientIntensity, _SpecPow, _SpecIntensity, _CelThreshold, _ShadowIntensity, _NormalStrength;

                                // unity defined variables
                uniform float4 _LightColor0;

                v2f vert(appdata v)
                {
                    v2f o;
                    o.uv = TRANSFORM_TEX(v.uv, _MainTexture);
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.normal = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
                    o.viewdir = normalize(WorldSpaceViewDir(v.vertex));
                                    //in world coords
                    o.tangent = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
                    o.binormal = normalize(cross(o.normal, o.tangent) * v.tangent.w);

                    return o;
                }

                float4 frag(v2f i) : SV_TARGET
                {
                    float3 viewDirection = i.viewdir;
                                    //get normal direction
                    float3 normalDirection = i.normal;
                                    //get light direction
                    float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);

                    float2 uv = TRANSFORM_TEX(i.uv, _MainTexture);
                    float3 albedo = tex2D(_MainTexture, uv).rgb;
                                    //albedo *= 1 - _SpecColor.rgb;
                    
                    i.col.rgb = albedo;
                    i.col.a = 1.0;
    
                    float3 tangentNormal = UnpackNormal(tex2D(_NormalMap, i.uv));
                    float3x3 TBN = float3x3((i.tangent), (i.binormal), (i.normal));
    
                    TBN = transpose(TBN);
    
                    float worldNormal = mul(TBN, tangentNormal);
                    normalDirection = worldNormal;

                                    //diffuse reflection
                    float3 diffuseReflection = dot(normalDirection, lightDirection);
                    diffuseReflection = max(0.0, diffuseReflection) * _Attenuation;

                                    //specular reflection
                    float3 x = reflect(-lightDirection, normalDirection);
                    float3 specularReflection = dot(x, viewDirection);
                    specularReflection = pow(max(0.0, specularReflection), _SpecPow) * _SpecIntensity;
                                    //---BLINN-PHONG
                    float3 halfDirection = normalize(lightDirection + viewDirection);
                    float specAngle = max(0.0, dot(halfDirection, normalDirection));
                    specularReflection = pow(specAngle, _SpecPow) * _SpecIntensity;
                                    //---
                    specularReflection *= diffuseReflection;
                    specularReflection *= _SpecColor.rgb;

                    float3 lightFinal = diffuseReflection;

                                    //use default ambient
                                    //lightFinal += UNITY_LIGHTMODEL_AMBIENT.rgb;
                                    //use custom ambient
                    lightFinal += (_Color.rgb * _AmbientIntensity);
                    lightFinal += specularReflection;

                                    //visualize
                    i.col.rgb += lightFinal;
    
                    //visualize things
                    //i.col.rgb = tangentNormal;

                    return i.col;
                }
                ENDCG
            }

            Pass
            {
                Cull Front                

                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "UnityCG.cginc"

                struct appdata
                {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                };

                struct v2f
                {
                    float4 vertex : SV_POSITION;
                };

                fixed4 _Color;
                float _OutlineWidth;

                v2f vert(appdata v)
                {
                    v2f o;
                    v.vertex.xyz += _OutlineWidth * v.normal;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    return _Color;
                }
                ENDCG
            }
        }
}