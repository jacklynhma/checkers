import PieceTile from '../../src/components/PieceTile';

describe('PieceTile', () =>{
  let wrapper;
  beforeEach(()=> {
    jasmineEnzyme();

    wrapper = mount(
      <PieceTile
        piece = "R"
      />
    )
  })
  it('should render p tag', () => {
    expect(wrapper.find('p')).toBePresent()
    expect(wrapper.find('p').text()).toBe("R")
  })
})
