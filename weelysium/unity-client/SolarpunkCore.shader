// WeeLysium Solarpunk Core Shader (v1.0)
// Designed for Unity Universal Render Pipeline (URP)
// Features: Vertex Softening, Stylized Saturation, and Philanthropic Glow

Shader "WeeLysium/SolarpunkCore"
{
    Properties
    {
        [Header(Base Aesthetics)]
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _Saturation("Saturation Boost", Range(0, 2)) = 1.3
        
        [Header(Softness and Bevel)]
        _Softness("Vertex Inflation (Soft Edges)", Range(0, 0.05)) = 0.01
        _Smoothness("Lighting Softness", Range(0, 1)) = 0.5

        [Header(Philanthropic Glow)]
        [HDR] _GlowColor("Upgraded Community Glow", Color) = (0, 1, 0.5, 1)
        _GlowIntensity("Glow Intensity", Range(0, 10)) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }
        LOD 100

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS   : TEXCOORD0;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float _Saturation;
                float _Softness;
                float _Smoothness;
                float4 _GlowColor;
                float _GlowIntensity;
            CBUFFER_END

            // Helper to boost colors for the Solarpunk look
            float3 ApplySaturation(float3 color, float amount)
            {
                float luma = dot(color, float3(0.299, 0.587, 0.114));
                return lerp(luma.xxx, color, amount);
            }

            Varyings vert(Attributes input)
            {
                Varyings output;

                // Vertex Softening: Inflates the mesh slightly to hide sharp low-poly edges
                float3 softPositionOS = input.positionOS.xyz + (input.normalOS * _Softness);
                
                output.positionCS = TransformObjectToHClip(softPositionOS);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                Light mainLight = GetMainLight();
                float3 normal = normalize(input.normalWS);
                
                // Soft Lambertian Lighting (wraps light around edges)
                float diffuse = saturate((dot(normal, mainLight.direction) + _Smoothness) / (1.0 + _Smoothness));
                
                // Combine colors and lighting
                float3 finalColor = _BaseColor.rgb * mainLight.color * diffuse;
                
                // Apply our signature Solarpunk saturation boost
                finalColor = ApplySaturation(finalColor, _Saturation);

                // Add the Community Glow (used when a player spends Wee-Credits)
                finalColor += (_GlowColor.rgb * _GlowIntensity);

                return half4(finalColor, 1.0);
            }
            ENDHLSL
        }
    }
}