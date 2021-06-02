import * as React from 'react';

export interface IHelloWorldProps {
	name?: string;
}

export class HelloWorld extends React.Component<IHelloWorldProps> {
  render() {
    return <h1>Hello {this.props.name}</h1>;
  }
}