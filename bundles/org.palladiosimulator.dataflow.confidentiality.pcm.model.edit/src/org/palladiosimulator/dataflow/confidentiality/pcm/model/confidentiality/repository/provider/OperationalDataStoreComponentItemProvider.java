package org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.repository.provider;

import java.util.Optional;

import org.eclipse.emf.common.notify.AdapterFactory;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.repository.OperationalDataStoreComponent;

public class OperationalDataStoreComponentItemProvider extends OperationalDataStoreComponentItemProviderGen {

    public OperationalDataStoreComponentItemProvider(AdapterFactory adapterFactory) {
        super(adapterFactory);
    }

    @Override
    public String getText(Object object) {
        if (object instanceof OperationalDataStoreComponent) {
            OperationalDataStoreComponent store = (OperationalDataStoreComponent) object;
            String type = getString("_UI_OperationalDataStoreComponent_type");
            String name = Optional.ofNullable(store.getEntityName()).orElse("");
            return String.format("%s %s", type, name);
        }
        return super.getText(object);
    }

}
