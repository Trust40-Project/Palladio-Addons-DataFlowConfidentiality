package org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.behaviour.provider;

import java.util.Optional;

import org.eclipse.emf.common.notify.AdapterFactory;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.behaviour.DataChannelBehaviour;

public class DataChannelBehaviourItemProvider extends DataChannelBehaviourItemProviderGen {

    /**
     * {@inheritDoc}
     */
    public DataChannelBehaviourItemProvider(AdapterFactory adapterFactory) {
        super(adapterFactory);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String getText(Object object) {
        if (object instanceof DataChannelBehaviour) {
            var behavior = (DataChannelBehaviour)object;
            var type = getString("_UI_DataChannelBehaviour_type");
            var name = Optional.ofNullable(behavior.getEntityName()).orElse("");
            var id = Optional.ofNullable(behavior.getId()).orElse("");
            return String.format("%s %s (%s)", type, name, id);
        }
        return super.getText(object);
    }

}
