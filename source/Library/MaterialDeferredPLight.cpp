#include "MaterialDeferredPLight.h"
#include "GameException.h"
#include "Mesh.h"

namespace Library {

	RTTI_DEFINITIONS(MaterialDeferredPLight);

	MaterialDeferredPLight::MaterialDeferredPLight()
		: MATERIAL_VARIABLES_INITIALIZATION(ScreenResolution, VP, CameraPosition, World,
											LightColor, LightPosition, LightAttenuation,
											PositionBuffer, NormalBuffer, AlbedoSpecularBuffer)
		Material() {}

	MATERIAL_VARIABLES_DEFINITION(MaterialDeferredPLight,
								  ScreenResolution, VP, CameraPosition, World,
								  LightColor, LightPosition, LightAttenuation,
								  PositionBuffer, NormalBuffer, AlbedoSpecularBuffer);

	void MaterialDeferredPLight::init(Effect* effect) {
		Material::init(effect);
		MATERIAL_VARIABLES_RETRIEVE(ScreenResolution, VP, CameraPosition, World,
									LightColor, LightPosition, LightAttenuation,
									PositionBuffer, NormalBuffer, AlbedoSpecularBuffer);
	}

	void MaterialDeferredPLight::create_vertex_buffer(ID3D11Device* device, const Mesh& mesh, ID3D11Buffer** buffer) const {
		const auto& src_vertices = mesh.vertices();
		std::vector<XMFLOAT4> vertices;
		vertices.reserve(src_vertices.size());
		for (UINT i = 0; i < src_vertices.size(); i++) {
			XMFLOAT3 pos = src_vertices.at(i);
			vertices.push_back(XMFLOAT4(pos.x, pos.y, pos.z, 1.0f));
		}
		Material::create_buffer(device, reinterpret_cast<void*>(&vertices[0]),
								vertices.size(), vertex_size(),
								D3D11_USAGE_IMMUTABLE, buffer);
	}

	UINT MaterialDeferredPLight::vertex_size() const {
		return sizeof(XMFLOAT4);
	}

}