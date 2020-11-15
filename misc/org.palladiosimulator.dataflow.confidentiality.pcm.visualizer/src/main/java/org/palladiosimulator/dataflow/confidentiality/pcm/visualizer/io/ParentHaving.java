package org.palladiosimulator.dataflow.confidentiality.pcm.visualizer.io;

public abstract class ParentHaving<T extends DataFlowResultElement> implements DataFlowResultElement {

	private transient T parent;

	public T getParent() {
		return parent;
	}

	public void setParent(T parent) {
		this.parent = parent;
		setParentForChildren();
	}

	protected abstract void setParentForChildren();

}
