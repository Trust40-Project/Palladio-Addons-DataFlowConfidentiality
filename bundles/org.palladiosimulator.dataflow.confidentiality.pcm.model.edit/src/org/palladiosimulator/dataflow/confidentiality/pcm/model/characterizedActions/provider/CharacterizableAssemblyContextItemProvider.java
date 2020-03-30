package org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.provider;

import java.util.Optional;

import org.eclipse.emf.common.notify.AdapterFactory;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.CharacterizableAssemblyContext;
import org.palladiosimulator.pcm.core.provider.PalladioComponentModelEditPlugin;

public class CharacterizableAssemblyContextItemProvider extends CharacterizableAssemblyContextItemProviderGen {

	public CharacterizableAssemblyContextItemProvider(AdapterFactory adapterFactory) {
		super(adapterFactory);
	}

	public String getText(Object object) {
		return Optional.ofNullable(object)
				.filter(CharacterizableAssemblyContext.class::isInstance)
				.map(CharacterizableAssemblyContext.class::cast)
				.map(CharacterizableAssemblyContext::getEntityName)
				.map(name -> getString("_UI_CharacterizableAssemblyContext_type") + " " + name)
				.orElse(super.getText(object));
	}

	@Override
	public Object getImage(Object object) {
		return Optional.ofNullable(PalladioComponentModelEditPlugin.INSTANCE)
				.map(PalladioComponentModelEditPlugin::getPluginResourceLocator)
				.map(l -> l.getImage("full/obj16/AssemblyContext"))
				.map(img -> this.overlayImage(object, img))
				.orElseGet(() -> super.getImage(object));
	}
	
}
